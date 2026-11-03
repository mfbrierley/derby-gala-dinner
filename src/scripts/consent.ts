/**
 * Cookie consent state, shared by the cookie banner and anything that needs consent
 * (the Google map on the event details page).
 *
 * The choice itself is stored in localStorage (strictly necessary, so no consent needed for it).
 * Listen for `dgd:consent` on `document` to react when the choice changes.
 */

export type Consent = 'accepted' | 'rejected';

const KEY = 'dgd-cookie-consent';
export const CONSENT_EVENT = 'dgd:consent';

export function getConsent(): Consent | null {
  try {
    const value = window.localStorage.getItem(KEY);
    return value === 'accepted' || value === 'rejected' ? value : null;
  } catch {
    return null;
  }
}

export function setConsent(value: Consent) {
  try {
    window.localStorage.setItem(KEY, value);
  } catch {
    // Storage blocked: the choice applies for this page view only.
  }
  document.dispatchEvent(new CustomEvent<Consent>(CONSENT_EVENT, { detail: value }));
}
