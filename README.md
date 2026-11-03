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

1. Run `npm run build`.
2. Connect to the IONOS web space with your SFTP client and open the directory the domain points to.
3. Upload **the contents of `dist/`** (not the `dist` folder itself) into that directory, replacing what's there.
   - Make sure `.htaccess` is uploaded too. SFTP clients often hide dotfiles.
   - Old files in `_astro/` can be deleted. Their names change on every build.

`.htaccess` forces HTTPS, redirects `www.` to the bare domain, serves the custom 404 page and sets caching.

If the site ever has to live in a sub-folder (e.g. `derbygaladinner.co.uk/new/`), set `base: '/new'` in
`astro.config.mjs` and rebuild.

## Where things are

| Path | What |
|---|---|
| `src/pages/` | One file per page (`index.astro` is the home page) |
| `src/layouts/Base.astro` | Page shell: `<head>`, fonts, header, footer, pop-ups, cookie banner |
| `src/components/` | Header, footer, enquiry/contact pop-up, cookie banner and shared sections |
| `src/styles/global.css` | Colours, fonts, buttons and the sizing system (see the comment at the top) |
| `src/assets/` | Images and SVGs from the Figma. Astro resizes the photos and converts them to WebP at build time |
| `src/config.ts` | Adobe Fonts project, Web3Forms key, hCaptcha key, Bridge the Gap link |
| `public/` | Copied as-is: `.htaccess`, `favicon.svg`, `robots.txt` |
| `PLACEHOLDERS.md` | Placeholder copy, unapproved copy and open questions |

## Fonts

Fonts come from Will's Adobe Fonts web project (`https://use.typekit.net/hfo7qtb.css`):
`arteria-std-compress` (big headings), `larken` (gold serif lines and labels), `sofia-pro` (body text, nav, buttons).
Adobe serves them; they can't be self-hosted. The site keeps working only while that Creative Cloud subscription is active.

## Forms

Both pop-ups (the table/sponsorship enquiry and the general contact form) post to
[Web3Forms](https://web3forms.com), which emails each submission to the address the access key belongs to.
Spam protection: Web3Forms' own filtering, a hidden honeypot field, and hCaptcha (switch hCaptcha on in the Web3Forms dashboard).

Buttons open the pop-ups with data attributes:

```html
<a href="/book-a-table/" data-open-enquiry="VIP Table">Book a table</a>
<a href="/book-a-table/#sponsorship" data-open-enquiry="Sponsorship" data-package="Headline sponsorship">Secure your sponsorship now</a>
<a href="#contact" data-open-contact>CONTACT</a>
```

## Cookies

The only non-essential cookies come from the live Google map on the event details page. It loads only after
the visitor accepts in the cookie banner. The choice is kept in `localStorage` (`dgd-cookie-consent`); see
`src/scripts/consent.ts`.
