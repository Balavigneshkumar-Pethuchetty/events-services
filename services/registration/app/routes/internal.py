"""Internal endpoints — only reachable by other containers on society_net.
Protected by X-Internal-Key header; never proxied through nginx.

Exists so that user-service's leave-society flow (activity export + final
account erase) no longer reads/deletes `registration_svc.*` rows directly —
see EVENTS_SERVICE_PLAN.md, coupling C1. Notification cleanup stays with
user-service: `erase` returns the deleted registration ids so it can clear
`core.notification` rows that point at them.
"""
from fastapi import APIRouter, Depends

from app.auth import require_internal_key
from app.database import get_pool
from app.models import MemberEraseOut, RegistrationActivityInternal

router = APIRouter(dependencies=[Depends(require_internal_key)])


@router.get("/members/{user_id}/activity", response_model=list[RegistrationActivityInternal],
            summary="A user's registration history (account-deletion activity export)")
async def member_activity(user_id: str, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT event_id::text, status, ticket_count, total_amount, registered_at "
            "FROM registration WHERE user_id = $1::uuid ORDER BY registered_at DESC",
            user_id,
        )
    return [dict(r) for r in rows]


@router.post("/members/{user_id}/erase", response_model=MemberEraseOut,
             summary="Delete all of a user's registrations (+ legacy payment/refund rows). Idempotent.")
async def member_erase(user_id: str, pool=Depends(get_pool)):
    async with pool.acquire() as conn:
        async with conn.transaction():
            await conn.execute(
                "DELETE FROM refund WHERE payment_id IN "
                "(SELECT id FROM payment WHERE registration_id IN "
                "(SELECT id FROM registration WHERE user_id = $1::uuid))",
                user_id,
            )
            await conn.execute(
                "DELETE FROM payment WHERE registration_id IN "
                "(SELECT id FROM registration WHERE user_id = $1::uuid)",
                user_id,
            )
            # ticket / registration_item / complimentary_ticket rows go with it
            # via ON DELETE CASCADE.
            rows = await conn.fetch(
                "DELETE FROM registration WHERE user_id = $1::uuid RETURNING id::text", user_id,
            )
    return {"deleted_ids": [r["id"] for r in rows]}
