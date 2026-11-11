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
| **Deploy test copy** | Every push to `main` (or run it by hand) | The `new-private` folder inside `derbygaladinner` - derbygaladinner.co.uk/new-private/, hidden from search engines |
| **Deploy live site** | When you run it: GitHub > **Actions** > **Deploy live site** > **Run workflow** | The `derbygaladinner` folder - derbygaladinner.co.uk |

Each run builds the site and uploads it with `scripts/deploy-sftp.sh`: new photos, scripts and
styles first, then the pages, then it removes `_astro` files the new pages no longer use. A run
takes a couple of minutes; you can watch it, and see any errors, on the Actions tab.

GitHub logs in with an SFTP account that IONOS restricts to the `derbygaladinner` folder. That
account sees the folder as `/`, so to the deploy the live site is `/` and the test copy is
`/new-private`. (Your own Cyberduck login sees the whole web space, where the same folders are
`/derbygaladinner` and `/derbygaladinner/new-private`.)

### Other clients' sites share this web space

The web space holds VOLT7's other clients' folders, side by side with `derbygaladinner`. The
deploy is built so it can't touch them:

1. **Restricted SFTP login (IONOS).** The server itself stops GitHub's account reaching anything
   outside `derbygaladinner`, whatever the code does.
2. **The login is checked.** Before anything else the script checks, read-only, that the login's
   top folder holds the `.dgd-deploy-live` permission file, i.e. it really is the
   `derbygaladinner` folder. A login that sees the whole web space (like your own) has no such
   file at its top, so every deploy with it is refused.
3. **Two fixed folders.** The script only ever writes to `/` (live) or `/new-private` (test), as
   the restricted login sees them. They're written into the script, not taken from settings;
   anything else is refused before connecting.
4. **The build must match the folder.** A test build only goes to the test folder, a live build
   only to the live folder.
5. **Permission files placed by hand.** The target folder must contain an empty file called
   `.dgd-deploy-live` (live folder) or `.dgd-deploy-test` (test folder), and not the other one.
   The deploy never creates them; they're blocked from the web by `.htaccess`.
6. **Build checks.** A broken or incomplete build is refused, so it can't clear out the site's
   images.

Inside the target folder it only ever deletes from `_astro`; everything else (the old site's
leftovers, `new-private` inside the live folder) is left alone. This was tested against a copy of
the web space with 15 client folders laid out like this one, with both a restricted and a
whole-web-space login, in 37 right and wrong scenarios: nothing outside the target folder changed
in any of them.

### One-time setup

**1. A restricted SFTP account for GitHub.** IONOS > Hosting > your package > **SFTP & SSH** >
create a new account, and set its **Directory** to the `derbygaladinner` folder.

**2. The login, as GitHub secrets.** The repository > **Settings** > **Secrets and variables** >
**Actions** > **New repository secret**:

| Secret name | Value |
|---|---|
| `IONOS_SFTP_HOST` | The server, e.g. `access-5012345678.webspace-data.io` (no `sftp://`) |
| `IONOS_SFTP_USER` | The restricted account's user name |
| `IONOS_SFTP_PASSWORD` | Its password |

Secrets are encrypted: nobody can read them back, including in the workflow logs.

**3. No folder variables.** The workflows default to `/new-private` (test) and `/` (live). If
`IONOS_TEST_DIR` or `IONOS_LIVE_DIR` exist on the **Variables** tab, delete them (or set them to
exactly those values).

**4. The permission files.** In Cyberduck (View > Show Hidden Files), File > New File: an empty
file called `.dgd-deploy-live` in the `derbygaladinner` folder, and one called `.dgd-deploy-test`
in `derbygaladinner/new-private`. Without them every deploy is refused.

### The two builds

| Command | For | Notes |
|---|---|---|
| `npm run build:test` | `/new-private/` | Every link and image path starts `/new-private/`; pages say `noindex` |
| `npm run build` | `/` (the root) | The live site |

The build has to match the folder: a root build uploaded into `/new-private/` shows no images.
To use a different test folder, change `BASE_PATH=/new-private` in `package.json` and `TEST_DIR`
in `scripts/deploy-sftp.sh`.

### Uploading by hand (if ever needed)

The same upload script can run on a Mac (`brew install lftp` first), after the matching build,
with the restricted account's login:

```bash
IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD='...' scripts/deploy-sftp.sh /new-private
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
| `src/layouts/Base.astro` | Page shell: `<head>`, fonts, header, footer, pop-ups |
| `src/components/` | Header, footer, enquiry/contact pop-up and shared sections |
| `src/assets/video/hero-bars.mp4` | Home hero background video (the poster is `src/assets/images/hero-bars-poster.jpg`, its first frame) |
| `src/data/sponsors.ts` | Sponsor names, labels and logos (shown in the home hero and the footer) |
| `src/styles/global.css` | Colours, fonts, buttons and the sizing system (see the comment at the top). `--type-scale` makes all text bigger or smaller (1 = Figma sizes) |
| `src/assets/` | Images and SVGs from the Figma. Astro resizes the photos and converts them to WebP at build time |
| `src/config.ts` | Adobe Fonts project, enquiry form endpoint, spam-check site key, Bridge The Gap link |
| `public/api/enquiry.php` | Receives the enquiry forms and emails them through Resend (see Enquiry forms) |
| `enquiry.config.json` | The address the enquiry emails are sent from |
| `public/` | Copied as-is: `.htaccess`, `favicon.svg`, `robots.txt` |
| `src/assets/gallery/` | Photos for the 2026 Gallery page (filename order; see the README there) |
| `PLACEHOLDERS.md` | Placeholder copy, unapproved copy and open questions |

## Fonts

Fonts come from Will's Adobe Fonts web project (`https://use.typekit.net/hfo7qtb.css`):
`arteria-std-compress` (big headings), `larken` (gold serif lines and labels), `sofia-pro` (body text, nav, buttons).
Adobe serves them; they can't be self-hosted. The site keeps working only while that Creative Cloud subscription is active.

## Enquiry forms

All three pop-ups (Reserve a table, Sponsorship enquiry and the general contact form) post to the
site's own endpoint, `public/api/enquiry.php`, a single PHP file that runs on the IONOS web space.
It checks the submission, then sends one email through [Resend](https://resend.com) with Reply-To
set to the enquirer, so replying to the email writes back to them. The comment at the top of the
file lists everything it checks.

| Setting | Where | What |
|---|---|---|
| `RESEND_API_KEY` | GitHub secret | Resend API key (sending access only) |
| `TURNSTILE_SECRET_KEY` | GitHub secret | Cloudflare Turnstile secret key |
| `TURNSTILE_SITEKEY` | GitHub variable | Cloudflare Turnstile site key (the public half of the pair) |
| `ENQUIRY_TO` | GitHub variable | Where enquiries are delivered (see below) |
| `from` | `enquiry.config.json` | The sender. Must be on the domain verified in Resend |

Secrets and variables are both under the repository's **Settings** > **Secrets and variables** >
**Actions** (two tabs). To change who receives enquiries, edit `ENQUIRY_TO` and run the deploy again.

`ENQUIRY_TO` is either one inbox for every form (several addresses: separate with commas):

```
someone@example.com
```

or an inbox per form, as `form: address` pairs separated by semicolons. The forms are `booking`,
`sponsorship` and `contact`; `default` covers any not named:

```
booking: tables@example.com; default: hello@example.com
```

The deploy stops with a message if an address is mistyped or a form has no inbox.

After each build the deploy workflows run `scripts/write-form-config.mjs`, which writes the keys
into `dist/api/config.php` beside the endpoint. That file is never in the repository, and
`.htaccess` stops it being served. The upload is refused if it's missing, or if the build used
Cloudflare's test key.

Spam protection: the Turnstile check, a hidden field that only bots fill in, and limits on how many
enquiries one visitor (5 in 15 minutes) and the whole site (60 a day) can send, so a flood can't
use up the Resend allowance. Only the fields and choices listed in the PHP file are accepted, and
the recipient can't be changed by anything a visitor sends.

Checking it's alive: opening `/api/enquiry.php` in a browser shows `{"ok":true,"ready":true}`
("ok": PHP is running; "ready": the settings file is in place).

**The forms can't send from `npm run dev` or the Vercel previews**, because neither runs PHP. To try
them on your own machine (needs PHP), with Cloudflare's always-passes test keys and your Resend key:

```bash
npm run build
RESEND_API_KEY=re_... TURNSTILE_SECRET_KEY=1x0000000000000000000000000000000AA ENQUIRY_TO=you@example.com node scripts/write-form-config.mjs
php -S localhost:8080 -t dist
```

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

The site sets no cookies of its own and has no cookie banner. Cloudflare Turnstile loads when an enquiry
form is opened and may store what it needs for its spam check. The venue map is a plain link to
Google Maps ("View on maps" on the event details page), not an embedded map.
