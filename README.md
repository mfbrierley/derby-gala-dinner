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

Deploys run through GitHub Actions (`.github/workflows/`):

| What | When | Goes to |
|---|---|---|
| **Deploy test copy** | Every push to `main` (or run it by hand) | `/derbygaladinner/new-private` - derbygaladinner.co.uk/new-private/, hidden from search engines |
| **Deploy live site** | When you run it: GitHub > **Actions** > **Deploy live site** > **Run workflow** | `/derbygaladinner` - derbygaladinner.co.uk |

Each run builds the site and uploads it with `scripts/deploy-sftp.sh`: new photos, scripts and
styles first, then the pages, then it removes `_astro` files the new pages no longer use. A run
takes a couple of minutes; you can watch it, and see any errors, on the Actions tab.

### Other clients' sites share this web space

The SFTP login can see VOLT7's other clients' folders, side by side with `derbygaladinner`. The
deploy is built so it can't touch them:

1. **Restricted SFTP login (IONOS).** GitHub has its own SFTP account, limited in IONOS to the
   `derbygaladinner` folder, so the server itself refuses anything outside it, whatever the code
   does. *(Set this up if it isn't: see below.)*
2. **Two fixed folders.** The script only ever writes to `/derbygaladinner` (live) or
   `/derbygaladinner/new-private` (test). They're written into the script, not taken from
   settings; anything else is refused before connecting.
3. **The build must match the folder.** A test build only goes to the test folder, a live build
   only to the live folder.
4. **Permission files placed by hand.** The script checks, read-only, that the target folder
   contains an empty file called `.dgd-deploy-live` (live folder) or `.dgd-deploy-test` (test
   folder) before writing anything. The deploy never creates them; they're blocked from the web by
   `.htaccess`.
5. **Build checks.** A broken or incomplete build is refused, so it can't clear out the site's
   images.

Inside the target folder it only ever deletes from `_astro`; everything else (the old site's
leftovers, `new-private` inside the live folder) is left alone. This was tested against a copy of
the web space with 15 client folders laid out like this one, in 33 right and wrong scenarios:
nothing outside the target folder changed in any of them.

### One-time setup

**1. A restricted SFTP account for GitHub.** IONOS > Hosting > your package > **SFTP & SSH** >
create a new account, and set its **Directory** to the `derbygaladinner` folder. Connect with it
in Cyberduck once to check it can only see that folder, and note the folder path Cyberduck shows
(if it's `/` rather than `/derbygaladinner`, the two fixed folders in `scripts/deploy-sftp.sh`
need changing to match).

**2. The login, as GitHub secrets.** The repository > **Settings** > **Secrets and variables** >
**Actions** > **New repository secret**:

| Secret name | Value |
|---|---|
| `IONOS_SFTP_HOST` | The server, e.g. `access-5012345678.webspace-data.io` (no `sftp://`) |
| `IONOS_SFTP_USER` | The restricted account's user name |
| `IONOS_SFTP_PASSWORD` | Its password |

Secrets are encrypted: nobody can read them back, including in the workflow logs.

**3. The folders, as GitHub variables** (same page, **Variables** tab):

| Variable name | Value |
|---|---|
| `IONOS_TEST_DIR` | `/derbygaladinner/new-private` |
| `IONOS_LIVE_DIR` | `/derbygaladinner` |

**4. The permission files.** In Cyberduck (View > Show Hidden Files), File > New File: an empty
file called `.dgd-deploy-live` in `/derbygaladinner`, and one called `.dgd-deploy-test` in
`/derbygaladinner/new-private`. Without them every deploy is refused.

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
