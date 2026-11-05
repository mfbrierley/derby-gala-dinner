# Derby Gala Dinner website

Static website for the Derby Gala Dinner, built with [Astro](https://astro.build) from Will's Figma design (`dgd`).

- **Previews:** Vercel builds every push to GitHub (private, for review).
- **Live site:** <https://derbygaladinner.co.uk/>, plain files uploaded to the IONOS web space by SFTP.

## Working on it

Needs Node 22.23.4 or newer.

```bash
npm install
npm run dev       # local dev server at http://localhost:4321
npm run build     # writes the finished site to dist/
npm run preview   # serves dist/ locally to check the build
```

## Deploying to IONOS

Deploys are automatic, through GitHub Actions (`.github/workflows/`):

| What | When | Goes to |
|---|---|---|
| **Deploy test copy** | Every push to `main` (or run it by hand) | `/derbygaladinner/new-private` - derbygaladinner.co.uk/new-private/, hidden from search engines |
| **Deploy live site** | Only when you run it: GitHub > **Actions** > **Deploy live site** > **Run workflow** | `/derbygaladinner` - derbygaladinner.co.uk |

Each run builds the site and uploads only what changed (`scripts/deploy-sftp.sh`): new photos,
scripts and styles first, then the pages, then it removes files the new pages no longer use. It
never touches anything outside its folder, and a live deploy leaves the `new-private` folder inside it alone. A run
takes a couple of minutes; you can watch it, and see any errors, on the Actions tab.

### One-time setup: the IONOS login

On GitHub: the repository > **Settings** > **Secrets and variables** > **Actions** >
**New repository secret**. Add three, with the values from IONOS (Hosting > your package >
**SFTP & SSH**):

| Secret name | Value |
|---|---|
| `IONOS_SFTP_HOST` | The server, e.g. `access-5012345678.webspace-host.com` (no `sftp://`) |
| `IONOS_SFTP_USER` | The SFTP user name |
| `IONOS_SFTP_PASSWORD` | That user's password |

Secrets are encrypted: nobody can read them back, including in the workflow logs. Until they're
added, the test deploy finishes with a warning and uploads nothing.

The domain points to the `derbygaladinner` folder of the web space, so the folders are set with
two repository **variables** (same page, **Variables** tab):

| Variable name | Value |
|---|---|
| `IONOS_LIVE_DIR` | `/derbygaladinner` |
| `IONOS_TEST_DIR` | `/derbygaladinner/new-private` |

Without them the workflows fall back to `/` and `/new-private` at the top of the web space,
which is outside the domain's folder.

### The two builds

| Command | For | Notes |
|---|---|---|
| `npm run build:test` | `/new-private/` | Every link and image path starts `/new-private/`; pages say `noindex` |
| `npm run build` | `/` (the root) | The live site |

The build has to match the folder: a root build uploaded into `/new-private/` shows no images.
To use a different test folder, change `BASE_PATH=/new-private` in `package.json` (and set
`IONOS_TEST_DIR`).

### Uploading by hand (if ever needed)

The same upload script can run on a Mac (`brew install lftp` first), after the matching build:

```bash
IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD='...' scripts/deploy-sftp.sh /derbygaladinner/new-private
```

Or with an SFTP app: upload the contents of `dist/` except `_astro`, overwriting; then the
`_astro` folder, choosing **Skip** for files that already exist (every file there is named after
its contents, so the same name means the same file). Make sure `.htaccess` goes up too: Macs and
SFTP apps hide files starting with a dot (in Finder, Cmd + Shift + . shows them).

`.htaccess` forces HTTPS, redirects `www.` to the bare domain, serves the custom 404 page and sets caching.

## Where things are

| Path | What |
|---|---|
| `src/pages/` | One file per page (`index.astro` is the home page) |
| `src/layouts/Base.astro` | Page shell: `<head>`, fonts, header, footer, pop-ups, cookie banner |
| `src/components/` | Header, footer, enquiry/contact pop-up, cookie banner and shared sections |
| `src/assets/video/hero-bars.mp4` | Home hero background video (the poster is `src/assets/images/hero-bars-poster.jpg`, its first frame) |
| `src/data/sponsors.ts` | Sponsor names, labels and logos (shown in the home hero and the footer) |
| `src/styles/global.css` | Colours, fonts, buttons and the sizing system (see the comment at the top). `--type-scale` makes all text bigger or smaller (1 = Figma sizes) |
| `src/assets/` | Images and SVGs from the Figma. Astro resizes the photos and converts them to WebP at build time |
| `src/config.ts` | Adobe Fonts project, Web3Forms key, hCaptcha key, Bridge the Gap link |
| `public/` | Copied as-is: `.htaccess`, `favicon.svg`, `robots.txt` |
| `src/assets/gallery/` | Photos for the 2026 Gallery page (filename order; see the README there) |
| `PLACEHOLDERS.md` | Placeholder copy, unapproved copy and open questions |

## Fonts

Fonts come from Will's Adobe Fonts web project (`https://use.typekit.net/hfo7qtb.css`):
`arteria-std-compress` (big headings), `larken` (gold serif lines and labels), `sofia-pro` (body text, nav, buttons).
Adobe serves them; they can't be self-hosted. The site keeps working only while that Creative Cloud subscription is active.

## Forms

All three pop-ups (Reserve a table, Sponsorship enquiry and the general contact form) post to
[Web3Forms](https://web3forms.com), which emails each submission to the address the access key belongs to.
Spam protection: Web3Forms' own filtering, a hidden honeypot field, and hCaptcha (switch hCaptcha on in the Web3Forms dashboard).

Buttons open the pop-ups with data attributes:

```html
<!-- Reserve a table, with the table type pre-selected (leave the value empty for none) -->
<a href="/book-a-table/" data-open-booking="VIP Table">Book a table</a>
<!-- Sponsorship enquiry, with one or more types ticked (comma-separated) -->
<a href="/book-a-table/#sponsorship" data-open-sponsorship="Headline">Secure your sponsorship now</a>
<!-- General enquiries -->
<a href="#contact" data-open-contact>CONTACT</a>
```

## Cookies

The only non-essential cookies come from the live Google map on the event details page. It loads only after
the visitor accepts in the cookie banner. The choice is kept in `localStorage` (`dgd-cookie-consent`); see
`src/scripts/consent.ts`.
