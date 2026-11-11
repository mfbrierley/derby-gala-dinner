// @ts-check
import { defineConfig } from 'astro/config';

// Static site: `npm run build` writes plain HTML/CSS/JS/images to `dist/`.
// Upload the *contents* of `dist/` to the IONOS directory over SFTP.
export default defineConfig({
  site: 'https://derbygaladinner.co.uk',
  output: 'static',
  trailingSlash: 'ignore',
  build: {
    // /event-details/ is written as /event-details/index.html, which Apache serves without any rewrite rules.
    format: 'directory',
    // Put the site's CSS inside each page rather than separate files: one less request
    // before the page can show (about 25 KB per page, 6 KB compressed).
    inlineStylesheets: 'always',
  },
});
