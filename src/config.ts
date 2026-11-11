export const SITE_NAME = 'Derby Gala Dinner';

// Adobe Fonts web project (owned by Will). Families: arteria-std-compress, larken, sofia-pro.
export const TYPEKIT_CSS = 'https://use.typekit.net/hfo7qtb.css';

// The enquiry forms post to the site's own endpoint (public/api/enquiry.php), which emails them
// through Resend. Path is relative to the site's root.
export const ENQUIRY_ENDPOINT = 'api/enquiry.php';

// Cloudflare Turnstile (the spam check on the forms). The site key is the public half of the
// pair; the deploy workflow passes it in from the GitHub variable TURNSTILE_SITEKEY. Without it
// (npm run dev, a build on your own machine) Cloudflare's test key is used, which always passes.
export const TURNSTILE_TEST_SITEKEY = '1x00000000000000000000AA';
export const TURNSTILE_SITEKEY: string = import.meta.env.PUBLIC_TURNSTILE_SITEKEY || TURNSTILE_TEST_SITEKEY;

export const BTG_URL = 'https://www.wearebridgethegap.com/';

// Venue, used for the address and the "View on maps" link on the event details page.
export const VENUE = {
  name: 'Vaillant Live Derby',
  address: '2 Colyear St, Derby DE1 1LA',
};
