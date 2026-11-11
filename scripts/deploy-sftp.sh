#!/usr/bin/env bash
#
# Upload the built site (dist/) to the IONOS web space over SFTP, sending only what changed.
# Used by the GitHub Actions workflow in .github/workflows/deploy-live.yml; can also be run by hand:
#
#   IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD=... scripts/deploy-sftp.sh
#
# THE WEB SPACE IS SHARED WITH OTHER CLIENTS' SITES (one folder each at the top level). This script
# must never write to, or delete from, anything outside the Derby Gala Dinner folder.
#
# The login it's given must be the restricted SFTP account IONOS limits to the derbygaladinner
# folder: that account sees the folder as "/". The server itself stops that account reaching
# anything else. On top of that, all checked before anything is written:
#
#   1. One fixed folder. The only folder this script will ever upload to is the login's top folder
#      ("/"). It's written into this file, not taken from settings or from the command line, so no
#      workflow variable or secret can point it anywhere else (any other folder is refused).
#   2. A permission file placed by hand. That folder must already contain an empty file named
#      .dgd-deploy-live, i.e. it really is the Derby Gala Dinner folder. It's created once, by a
#      person, in Cyberduck; this script never creates or uploads it. Checked over a read-only
#      connection first. A login that sees the whole web space (all clients' folders at its top)
#      has no such file there, and no other client's folder has one, so both are refused.
#   3. The build is the live one: built for the domain root and not marked "noindex" (as the
#      Vercel previews are).
#   4. The build looks complete (every page, enough files in _astro), so a broken build can't
#      clear out the site's own images; and the enquiry forms are ready to send (their endpoint
#      and its settings are there, and the spam check has its real key).
#
# What it then changes, and only inside that folder:
# - _astro/: new files are added (every file there is named after its contents, so a file that's
#   already on the server is identical and skipped); afterwards files the new pages no longer use
#   are removed. This is the only place anything is ever deleted.
# - The pages, .htaccess, robots.txt, favicon and api/ (the enquiry form endpoint and its
#   settings): always uploaded in full over the old copies. Nothing else in the folder is deleted.
# Order: new _astro files first, then the pages that use them, then the clean-up, so a visitor
# never gets a page whose files aren't there yet.

set -euo pipefail

# ---- 1. The fixed folder (the only place this script will ever write) --------------------------
SITE_DIR="/"
MARKER=".dgd-deploy-live"

refuse() {
  echo "REFUSED: $*" >&2
  echo "Nothing was uploaded or deleted." >&2
  exit 1
}

# No folder is needed. "/" (what the workflow passes) is accepted; anything else is refused.
[ $# -eq 0 ] || { [ $# -eq 1 ] && [ "$1" = "$SITE_DIR" ]; } ||
  refuse "this script only ever uploads to the live site's folder (${SITE_DIR}), not '$*'. Run it as scripts/deploy-sftp.sh"
: "${IONOS_SFTP_HOST:?IONOS_SFTP_HOST is not set}"
: "${IONOS_SFTP_USER:?IONOS_SFTP_USER is not set}"
: "${IONOS_SFTP_PASSWORD:?IONOS_SFTP_PASSWORD is not set}"
PORT="${IONOS_SFTP_PORT:-22}"

# ---- 3. The build is the live one --------------------------------------------------------------
[ -f dist/index.html ] && [ -d dist/_astro ] || refuse "dist/ isn't built: run npm run build first."
if grep -q 'name="robots" content="noindex' dist/index.html; then
  refuse "dist/ is a build that's hidden from search engines (noindex), not the live build. Run npm run build."
fi
grep -q '="/_astro/' dist/index.html ||
  refuse "dist/ wasn't built for the domain root (its file paths don't start /_astro/). Run npm run build."

# ---- 4. The build looks complete --------------------------------------------------------------
for page in index.html 404.html .htaccess book-a-table/index.html event-details/index.html \
  your-hosts/index.html gallery/index.html privacy-policy/index.html; do
  [ -f "dist/$page" ] || refuse "dist/ is missing ${page}: the build looks incomplete."
done
# The enquiry forms: the endpoint, its settings (keys; written after the build, never committed)
# and the real spam-check key. Without any of these the forms would look fine but couldn't send.
[ -f dist/api/enquiry.php ] || refuse "dist/ is missing api/enquiry.php: the build looks incomplete."
[ -f dist/api/config.php ] ||
  refuse "dist/api/config.php is missing, so the enquiry forms couldn't send. Run scripts/write-form-config.mjs after the build (the workflow does; see README > Enquiry forms)."
if grep -q 'data-turnstile-sitekey="1x00000000000000000000AA"' dist/index.html; then
  refuse "this build uses Cloudflare's test key for the forms' spam check, which only works on your own machine. Build with PUBLIC_TURNSTILE_SITEKEY set (on GitHub: the TURNSTILE_SITEKEY variable; see README > Enquiry forms)."
fi
ASSET_COUNT=$(find dist/_astro/ -type f | wc -l)
[ "$ASSET_COUNT" -ge 100 ] || refuse "dist/_astro has only ${ASSET_COUNT} files: the build looks incomplete."
if [ -n "$(find dist/ -name '.dgd-deploy-*' -print -quit)" ]; then
  refuse "dist/ contains a .dgd-deploy-* file. Those are placed on the server by hand only."
fi

# The password is passed through the environment, never on the command line.
export LFTP_PASSWORD="$IONOS_SFTP_PASSWORD"
LFTP_SETTINGS="set cmd:fail-exit yes
set net:max-retries 4
set net:reconnect-interval-base 5
set net:timeout 60
set sftp:auto-confirm yes"

# ---- 2. The permission file, checked over a read-only connection ------------------------------
# Lists the login's top folder (names only), changing nothing.
read_listing() {
  lftp <<EOF 2>&1
${LFTP_SETTINGS}
open --env-password -u "${IONOS_SFTP_USER}" -p ${PORT} sftp://${IONOS_SFTP_HOST}
cd "$1"
cls -1a
bye
EOF
}
has() { printf '%s\n' "$1" | grep -qxF -- "$2"; }

echo "Checking the login's top folder on ${IONOS_SFTP_HOST} (read-only) for ${MARKER}"
if ! LISTING=$(read_listing "$SITE_DIR"); then
  echo "$LISTING" >&2
  refuse "couldn't read the login's top folder (wrong login or password?)."
fi
has "$LISTING" "$MARKER" ||
  refuse "the login's top folder has no ${MARKER} file, so it isn't the Derby Gala Dinner folder. GitHub must use the SFTP account IONOS restricts to the derbygaladinner folder, and that folder needs the empty ${MARKER} file (see README > Deploying)."
echo "OK: this is the Derby Gala Dinner login and its folder is marked as the live site. Uploading."

ASSETS_DIR="${SITE_DIR%/}/_astro"

# The pages and settings (everything outside _astro, ~1 MB) are always uploaded in full, so a
# changed page can never be skipped as "the same". Every name is checked before it's used.
PAGE_FILES=$(cd dist && find . -path ./_astro -prune -o -type f -print | sed 's|^\./||' | sort)
while IFS= read -r f; do
  case "$f" in
    "" | *..* | /* | *[!A-Za-z0-9._/-]*) refuse "unexpected file name in dist/: '${f}'" ;;
  esac
done <<< "$PAGE_FILES"
PAGE_LIST=$(printf '%s ' $PAGE_FILES)

lftp <<EOF
${LFTP_SETTINGS}
open --env-password -u "${IONOS_SFTP_USER}" -p ${PORT} sftp://${IONOS_SFTP_HOST}
cd "${SITE_DIR}"
mkdir -p -f "${ASSETS_DIR}"
echo "1/3 New images, video, scripts and styles (_astro)"
mirror --reverse --only-missing --no-perms --parallel=4 --verbose=1 dist/_astro "${ASSETS_DIR}"
echo "2/3 Pages and settings"
set xfer:clobber on
lcd dist
mput -d ${PAGE_LIST}
lcd ..
echo "3/3 Removing _astro files the new pages no longer use"
mirror --reverse --only-missing --delete --no-perms --verbose=1 dist/_astro "${ASSETS_DIR}"
bye
EOF

echo "Done."
