"""Internal endpoints — only reachable by other containers on society_net.
Protected by X-Internal-Key header; never proxied through nginx.

Exists so that user-service's leave-society flow (blocker check, activity
export, final account erase) no longer reads/deletes `payment_svc.*` rows
directly — see EVENTS_SERVICE_PLAN.md, coupling C1. Notification cleanup
stays with user-service: `erase` returns the deleted transaction ids so it can
clear `core.notification` rows that point at them.
"""
from fastapi import APIRouter, Depends

from shared.auth_core import require_internal_key
from app.database import get_pool
from app.models import MemberBlockersInternal, MemberEraseOut, PaymentActivityInternal

router = APIRouter(dependencies=[Depends(require_internal_key)])


@router.get("/members/{user_id}/blockers", response_model=MemberBlockersInternal,
            summary="Payment-side reasons a user can't leave the society yet")
async def member_blockers(user_id: str, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        pending = await conn.fetch(
            "SELECT DISTINCT event_id::text FROM payment_transaction "
            "WHERE user_id = $1::uuid AND status IN ('pending', 'verified', 'refund_requested')",
            user_id,
        )
        collector = await conn.fetch(
            "SELECT DISTINCT event_id::text FROM committee_registry "
            "WHERE member_id = $1::uuid OR assigned_by = $1::uuid",
            user_id,
        )
        refunds = await conn.fetchval(
            "SELECT COUNT(*) FROM sponsorship_refund WHERE requested_by = $1::uuid", user_id,
        )
    return {
        "pending_payment_event_ids": [r["event_id"] for r in pending],
        "collector_event_ids": [r["event_id"] for r in collector],
        "open_sponsorship_refund_count": refunds,
    }


@router.get("/members/{user_id}/activity", response_model=list[PaymentActivityInternal],
            summary="A user's payment history (account-deletion activity export)")
async def member_activity(user_id: str, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT event_id::text, amount, currency, status, created_at "
            "FROM payment_transaction WHERE user_id = $1::uuid ORDER BY created_at DESC",
            user_id,
        )
    return [dict(r) for r in rows]


@router.post("/members/{user_id}/erase", response_model=MemberEraseOut,
             summary="Delete all of a user's payment transactions. Idempotent.")
async def member_erase(user_id: str, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        # payment_audit_log rows go with it via ON DELETE CASCADE.
        rows = await conn.fetch(
            "DELETE FROM payment_transaction WHERE user_id = $1::uuid RETURNING id::text", user_id,
        )
    return {"deleted_ids": [r["id"] for r in rows]}
