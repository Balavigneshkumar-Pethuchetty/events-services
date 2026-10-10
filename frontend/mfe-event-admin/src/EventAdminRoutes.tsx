import './i18n';
import { useTranslation } from 'react-i18next';
import { Box, Typography } from '@mui/material';
import { PaymentApprovals } from './pages/PaymentApprovals';
import { SponsorManagement } from './pages/SponsorManagement';
import { SponsorshipRefunds } from './pages/SponsorshipRefunds';
import { CategoryManagement } from './pages/CategoryManagement';
import { ReconciliationConsole } from './pages/ReconciliationConsole';
import { RefundTasks } from './pages/RefundTasks';

// The event-domain half of the /admin/* tree (EVENTS_SERVICE_PLAN.md C6). The
// shell's AdminWrapper sends a page here when it's in EVENT_ADMIN_PAGES, and
// everything else to mfe-admin's AdminRoutes. Keep both lists in sync.
export const EVENT_ADMIN_PAGES = ['payments', 'reconciliation', 'pay-refunds', 'sponsors', 'categories', 'refunds'];

interface EventAdminRoutesProps {
  token?: string | null;
  page?: string;
  role?: string;
}

const COMMITTEE_PAGES = new Set(['payments', 'reconciliation', 'pay-refunds']);

export function EventAdminRoutes({ token = null, page, role }: EventAdminRoutesProps) {
  const { t } = useTranslation('admin');
  const isCommittee = role === 'committee_member';

  // Committee members land on Payment Approvals by default
  const effectivePage = page || 'payments';

  // Block committee members from admin-only pages
  if (isCommittee && !COMMITTEE_PAGES.has(effectivePage)) {
    return (
      <Box component="main" sx={{ minHeight: 'calc(100vh - 64px)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 1.5, color: 'text.secondary' }}>
        <Typography fontSize={48} lineHeight={1}>🔒</Typography>
        <Typography variant="h5" color="text.primary">{t('common.accessDeniedTitle')}</Typography>
        <Typography variant="body2">{t('common.accessDeniedBody')}</Typography>
      </Box>
    );
  }

  if (effectivePage === 'sponsors')       return <SponsorManagement token={token} />;
  if (effectivePage === 'categories')     return <CategoryManagement token={token} />;
  if (effectivePage === 'refunds')        return <SponsorshipRefunds token={token} />;
  if (effectivePage === 'reconciliation') return <ReconciliationConsole token={token} role={role} />;
  if (effectivePage === 'pay-refunds')    return <RefundTasks token={token} />;
  return <PaymentApprovals token={token} role={role} />;
}
