// @ts-check
import { defineConfig } from 'astro/config';

// Static site: `npm run build` writes plain HTML/CSS/JS/images to `dist/`.
// Upload the *contents* of `dist/` to the IONOS directory over SFTP.
export default defineConfig({
  site: 'https://derbygaladinner.co.uk',
  // If the IONOS directory ends up being a sub-folder of the domain
  // (e.g. https://derbygaladinner.co.uk/new/), set `base: '/new'`.
  base: '/',
  output: 'static',
  trailingSlash: 'ignore',
  build: {
    // /event-details/ is written as /event-details/index.html, which Apache serves without any rewrite rules.
    format: 'directory',
  },
});
