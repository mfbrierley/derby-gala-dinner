#!/usr/bin/env node
/**
 * Writes dist/api/config.php: the settings the enquiry form endpoint (public/api/enquiry.php)
 * needs to send email. It holds secret keys, so it is never in the repository; the deploy
 * workflows run this after the build, with the values from GitHub:
 *
 *   RESEND_API_KEY        secret    Resend API key (starts re_)
 *   TURNSTILE_SECRET_KEY  secret    Cloudflare Turnstile secret key
 *   ENQUIRY_TO            variable  where enquiries are delivered (several: separate with commas)
 *
 * The sender ("from") is in enquiry.config.json. It must be on the domain verified in Resend.
 * (TURNSTILE_SITEKEY, the public half of the Turnstile pair, is used by the build, not here.)
 *
 * By hand, after `npm run build`:
 *   RESEND_API_KEY=... TURNSTILE_SECRET_KEY=... ENQUIRY_TO=... node scripts/write-form-config.mjs
 */
import { existsSync, readFileSync, writeFileSync } from 'node:fs';

const fail = (message) => {
  console.error(`write-form-config: ${message}`);
  process.exit(1);
};

const env = (name) => (process.env[name] ?? '').trim();
const missing = ['RESEND_API_KEY', 'TURNSTILE_SECRET_KEY', 'ENQUIRY_TO'].filter((name) => !env(name));
if (missing.length) {
  fail(
    `not set: ${missing.join(', ')}. Add them on GitHub under Settings > Secrets and variables > Actions ` +
      '(RESEND_API_KEY and TURNSTILE_SECRET_KEY as secrets, ENQUIRY_TO as a variable). See README > Enquiry forms.',
  );
}
if (!existsSync('dist/api/enquiry.php')) fail('dist/api/enquiry.php is missing: run the build first.');

const { from } = JSON.parse(readFileSync('enquiry.config.json', 'utf8'));
const isEmail = (value) => /^[^\s@<>,]+@[^\s@<>,]+\.[^\s@<>,]+$/.test(value);
const fromAddress = (/<([^<>]+)>\s*$/.exec(from ?? '')?.[1] ?? from ?? '').trim();
if (!isEmail(fromAddress)) fail(`enquiry.config.json: "from" isn't a sender address: ${JSON.stringify(from)}`);

const to = env('ENQUIRY_TO').split(',').map((address) => address.trim()).filter(Boolean);
const bad = to.filter((address) => !isEmail(address));
if (!to.length || bad.length) fail(`ENQUIRY_TO has something that isn't an email address: ${bad.join(', ') || '(empty)'}`);

// PHP single-quoted strings: only \ and ' need escaping.
const php = (value) => `'${String(value).replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
const settings = {
  resend_api_key: env('RESEND_API_KEY'),
  turnstile_secret: env('TURNSTILE_SECRET_KEY'),
  from,
  to: to.join(', '),
};
// Only for trying the forms without real services (see README).
for (const [key, name] of [['resend_url', 'RESEND_URL'], ['turnstile_url', 'TURNSTILE_URL']]) {
  if (env(name)) settings[key] = env(name);
}

const lines = Object.entries(settings).map(([key, value]) => `    ${php(key)} => ${php(value)},`);
writeFileSync(
  'dist/api/config.php',
  `<?php\n// Written by scripts/write-form-config.mjs at deploy time. Do not edit or commit.\nreturn [\n${lines.join('\n')}\n];\n`,
  { mode: 0o644 },
);
console.log(`Wrote dist/api/config.php (from ${fromAddress}, to ${to.length} address${to.length === 1 ? '' : 'es'}).`);
