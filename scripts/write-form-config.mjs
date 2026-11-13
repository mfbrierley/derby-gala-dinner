#!/usr/bin/env node
/**
 * Writes dist/api/config.php: the settings the enquiry form endpoint (public/api/enquiry.php)
 * needs to send email. It holds secret keys, so it is never in the repository; the deploy
 * workflow runs this after the build, with the values from GitHub:
 *
 *   RESEND_API_KEY        secret    Resend API key (starts re_)
 *   TURNSTILE_SECRET_KEY  secret    Cloudflare Turnstile secret key
 *   ENQUIRY_TO            variable  where enquiries are delivered. Either one inbox for every form
 *                                   (several addresses: separate with commas):
 *                                     someone@example.com
 *                                   or an inbox per form, as "form: address" pairs separated by
 *                                   semicolons. Form names are the ones in public/api/enquiry.php
 *                                   (booking, sponsorship, donation, contact); "default" covers the rest:
 *                                     booking: tables@example.com; default: hello@example.com
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

// A list of addresses, checked, as "a@x.com, b@y.com".
const addresses = (text, where) => {
  const list = text.split(',').map((address) => address.trim()).filter(Boolean);
  const bad = list.filter((address) => !isEmail(address));
  if (!list.length || bad.length) fail(`ENQUIRY_TO${where} has something that isn't an email address: ${bad.join(', ') || '(empty)'}`);
  return list.join(', ');
};

// The forms the endpoint knows, read from its FORMS list, so every one is sure to have an inbox.
const formNames = [...readFileSync('dist/api/enquiry.php', 'utf8').matchAll(/^ {4}'([a-z_]+)' => \[\n {8}'subject'/gm)].map((m) => m[1]);
if (!formNames.length) fail("couldn't read the form names from dist/api/enquiry.php.");

let to;
let toSummary;
if (/[:=]/.test(env('ENQUIRY_TO'))) {
  // An inbox per form: "booking: a@x.com; default: b@y.com"
  to = {};
  for (const pair of env('ENQUIRY_TO').split(/[;\n]/).map((part) => part.trim()).filter(Boolean)) {
    const match = /^([A-Za-z_]+)\s*[:=]\s*(.+)$/.exec(pair);
    if (!match) fail(`ENQUIRY_TO: can't read "${pair}". Write it as "form: address", with semicolons between forms.`);
    const name = match[1].toLowerCase();
    if (name !== 'default' && !formNames.includes(name)) {
      fail(`ENQUIRY_TO: there is no form called "${name}". The forms are: ${formNames.join(', ')} (or "default" for the rest).`);
    }
    if (to[name]) fail(`ENQUIRY_TO: "${name}" is listed twice.`);
    to[name] = addresses(match[2], ` (${name})`);
  }
  const uncovered = formNames.filter((name) => !to[name] && !to.default);
  if (uncovered.length) fail(`ENQUIRY_TO: no inbox for ${uncovered.join(', ')}. Add it, or add "default: address".`);
  toSummary = formNames.map((name) => `${name} to ${(to[name] ?? to.default).split(',').length}`).join(', ');
} else {
  to = addresses(env('ENQUIRY_TO'), '');
  toSummary = `every form to ${to.split(',').length}`;
}

// PHP single-quoted strings: only \ and ' need escaping.
const php = (value) => `'${String(value).replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
const settings = {
  resend_api_key: env('RESEND_API_KEY'),
  turnstile_secret: env('TURNSTILE_SECRET_KEY'),
  from,
  to,
};
// Only for trying the forms without real services (see README).
for (const [key, name] of [['resend_url', 'RESEND_URL'], ['turnstile_url', 'TURNSTILE_URL']]) {
  if (env(name)) settings[key] = env(name);
}

const phpValue = (value) =>
  typeof value === 'object'
    ? `[${Object.entries(value).map(([key, item]) => `${php(key)} => ${php(item)}`).join(', ')}]`
    : php(value);
const lines = Object.entries(settings).map(([key, value]) => `    ${php(key)} => ${phpValue(value)},`);
writeFileSync(
  'dist/api/config.php',
  `<?php\n// Written by scripts/write-form-config.mjs at deploy time. Do not edit or commit.\nreturn [\n${lines.join('\n')}\n];\n`,
  { mode: 0o644 },
);
// Counts only: the addresses themselves stay out of the deploy log.
console.log(`Wrote dist/api/config.php (from ${fromAddress}; number of inboxes: ${toSummary}).`);
