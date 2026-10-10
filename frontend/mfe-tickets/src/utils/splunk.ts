/**
 * Frontend error reporter — same contract as the shell's src/utils/splunk.ts:
 * posts to the user-service log proxy, which forwards to Splunk. This remote
 * has no Keycloak instance of its own, so identity is decoded from the token
 * the shell passes in (see setLogToken).
 */

const LOG_ENDPOINT = '/api/users/frontend-logs';
const _KNOWN_ROLES = new Set(['admin', 'committee_member', 'resident', 'security_guard', 'sponsor']);

let currentToken: string | null = null;

/** Called by the gate pages with the token they were given, so logs carry the caller. */
export function setLogToken(token: string | null): void {
  currentToken = token;
}

interface LogPayload {
  level?:  'error' | 'warn' | 'info';
  message: string;
  source?: string;
  url?:    string;
  stack?:  string;
  extra?:  Record<string, unknown>;
}

function getUserInfo(): Record<string, unknown> {
  try {
    const t = JSON.parse(atob((currentToken ?? '').split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
    const roles: string[] = t.realm_access?.roles ?? [];
    return {
      user_id:  t.sub,
      username: t.preferred_username,
      email:    t.email,
      name:     [t.given_name, t.family_name].filter(Boolean).join(' ') || t.preferred_username,
      role:     roles.find((r) => _KNOWN_ROLES.has(r)) ?? 'unknown',
    };
  } catch {
    return { user: 'anonymous' };
  }
}

/** Manually log an error from any component or service. */
export function logError(message: string, opts: Partial<LogPayload> = {}): void {
  const body = JSON.stringify({
    level: 'error', message, url: window.location.href, ...opts,
    extra: { ...opts.extra, ...getUserInfo() },
  });
  try {
    if (navigator.sendBeacon) {
      navigator.sendBeacon(LOG_ENDPOINT, new Blob([body], { type: 'application/json' }));
    } else {
      fetch(LOG_ENDPOINT, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body, keepalive: true })
        .catch(() => {});
    }
  } catch {
    // Never let logging throw
  }
}
