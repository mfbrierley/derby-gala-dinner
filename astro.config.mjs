// @ts-check
import { readFile, writeFile } from 'node:fs/promises';
import { defineConfig } from 'astro/config';

/**
 * Where on the domain the site lives. `npm run build` is for the domain root (the live site);
 * `npm run build:test` sets BASE_PATH=/new-private for the test copy in that folder.
 * Every link, image and script path in the build starts with this.
 */
const base = '/' + (process.env.BASE_PATH ?? '').replace(/^\/+|\/+$/g, '');

/**
 * .htaccess is a plain file (public/.htaccess); point its 404 page at the right folder.
 * @type {import('astro').AstroIntegration}
 */
const htaccessBase = {
  name: 'htaccess-base',
  hooks: {
    'astro:build:done': async ({ dir }) => {
      const file = new URL('.htaccess', dir);
      const text = await readFile(file, 'utf8');
      await writeFile(file, text.replace('ErrorDocument 404 /404.html', `ErrorDocument 404 ${base.replace(/\/$/, '')}/404.html`));
    },
  },
};

// Static site: `npm run build` writes plain HTML/CSS/JS/images to `dist/`.
// Upload the *contents* of `dist/` to the IONOS directory over SFTP.
export default defineConfig({
  site: 'https://derbygaladinner.co.uk',
  base,
  output: 'static',
  trailingSlash: 'ignore',
  integrations: [htaccessBase],
  build: {
    // /event-details/ is written as /event-details/index.html, which Apache serves without any rewrite rules.
    format: 'directory',
    // Put the site's CSS inside each page rather than separate files: one less request
    // before the page can show (about 25 KB per page, 6 KB compressed).
    inlineStylesheets: 'always',
  },
});
