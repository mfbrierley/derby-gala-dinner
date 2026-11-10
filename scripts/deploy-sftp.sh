#!/usr/bin/env bash
#
# Upload the built site (dist/) to the IONOS web space over SFTP, sending only what changed.
# Used by the GitHub Actions workflows in .github/workflows/; can also be run by hand:
#
#   IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD=... scripts/deploy-sftp.sh /derbygaladinner/new-private
#
# THE WEB SPACE IS SHARED WITH OTHER CLIENTS' SITES (one folder each at the top level). This script
# must never write to, or delete from, anything outside the Derby Gala Dinner folders. Four
# independent checks, all made before anything is written:
#
#   1. Fixed folders. The only folders this script will ever upload to are listed below
#      (LIVE_DIR, TEST_DIR). They're written into this file, not taken from settings, so no
#      workflow variable or secret can point it anywhere else. Anything else is refused before
#      connecting. Paths may only contain a-z, 0-9, "-" and "/".
#   2. The build must match the folder. A test build (npm run build:test: noindex, links under
#      /new-private/) can only go to TEST_DIR, a live build (npm run build) only to LIVE_DIR.
#   3. A permission file placed by hand. The target folder must already contain an empty file
#      named .dgd-deploy-live (live folder) or .dgd-deploy-test (test folder), and not the other
#      one. They're created once, by a person, in Cyberduck; this script never creates or uploads
#      them. Checked over a read-only connection first. No other client's folder has one, so even
#      a wrong path stops here.
#   4. The build looks complete (every page, enough files in _astro), so a broken build can't
#      clear out the site's own images.
#
# What it then changes, and only inside the checked folder:
# - _astro/: new files are added (every file there is named after its contents, so a file that's
#   already on the server is identical and skipped); afterwards files the new pages no longer use
#   are removed. This is the only place anything is ever deleted.
# - The pages, .htaccess, robots.txt, favicon: always uploaded in full over the old copies. Nothing
#   else in the folder is deleted (old files, other folders such as new-private/ are left alone).
# Order: new _astro files first, then the pages that use them, then the clean-up, so a visitor
# never gets a page whose files aren't there yet.

set -euo pipefail

# ---- 1. Fixed folders (the only places this script will ever write) ----------------------------
LIVE_DIR="/derbygaladinner"
TEST_DIR="/derbygaladinner/new-private"
LIVE_MARKER=".dgd-deploy-live"
TEST_MARKER=".dgd-deploy-test"

refuse() {
  echo "REFUSED: $*" >&2
  echo "Nothing was uploaded or deleted." >&2
  exit 1
}

[ $# -eq 1 ] || refuse "usage: scripts/deploy-sftp.sh ${TEST_DIR}   (or ${LIVE_DIR} for the live site)"
REMOTE_DIR="$1"
: "${IONOS_SFTP_HOST:?IONOS_SFTP_HOST is not set}"
: "${IONOS_SFTP_USER:?IONOS_SFTP_USER is not set}"
: "${IONOS_SFTP_PASSWORD:?IONOS_SFTP_PASSWORD is not set}"
PORT="${IONOS_SFTP_PORT:-22}"

case "$REMOTE_DIR" in
  *[!a-z0-9/-]*) refuse "the folder '${REMOTE_DIR}' contains characters other than a-z, 0-9, - and /." ;;
esac
SITE_DIR="${REMOTE_DIR%/}" # one trailing slash allowed: /derbygaladinner/ = /derbygaladinner
if [ "$SITE_DIR" != "$LIVE_DIR" ] && [ "$SITE_DIR" != "$TEST_DIR" ]; then
  refuse "'${REMOTE_DIR}' isn't one of the two folders this script may write to: ${LIVE_DIR} (live) or ${TEST_DIR} (test)."
fi

# ---- 2. The build must match the folder -------------------------------------------------------
[ -f dist/index.html ] && [ -d dist/_astro ] ||
  refuse "dist/ isn't built: run npm run build (live) or npm run build:test (test copy) first."
if grep -q 'name="robots" content="noindex' dist/index.html && grep -q 'href="/new-private/' dist/index.html; then
  BUILD="test"
elif ! grep -q 'name="robots" content="noindex' dist/index.html && ! grep -q 'new-private' dist/index.html; then
  BUILD="live"
else
  refuse "can't tell whether dist/ is a live or a test build (it has some signs of each). Rebuild."
fi
if [ "$BUILD" = "live" ]; then WANT_DIR="$LIVE_DIR"; MARKER="$LIVE_MARKER"; OTHER_MARKER="$TEST_MARKER"
else WANT_DIR="$TEST_DIR"; MARKER="$TEST_MARKER"; OTHER_MARKER="$LIVE_MARKER"; fi
[ "$SITE_DIR" = "$WANT_DIR" ] ||
  refuse "dist/ is a ${BUILD} build, which only goes to ${WANT_DIR}, not ${SITE_DIR}."

# ---- 4. The build looks complete --------------------------------------------------------------
for page in index.html 404.html .htaccess book-a-table/index.html event-details/index.html \
  your-hosts/index.html gallery/index.html privacy-policy/index.html; do
  [ -f "dist/$page" ] || refuse "dist/ is missing ${page}: the build looks incomplete."
done
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

# ---- 3. Permission file, checked over a read-only connection ----------------------------------
echo "Checking ${SITE_DIR} on ${IONOS_SFTP_HOST} (read-only) for its ${MARKER} file"
if ! LISTING=$(lftp <<EOF 2>&1
${LFTP_SETTINGS}
open --env-password -u "${IONOS_SFTP_USER}" -p ${PORT} sftp://${IONOS_SFTP_HOST}
cd "${SITE_DIR}"
cls -1a
bye
EOF
); then
  echo "$LISTING" >&2
  refuse "couldn't read ${SITE_DIR} (wrong login, or the folder doesn't exist)."
fi
has() { printf '%s\n' "$LISTING" | grep -qxF -- "$1"; }
has "$MARKER" ||
  refuse "${SITE_DIR} has no ${MARKER} file, so it isn't marked as the ${BUILD} folder. Create that empty file there by hand (see README > Deploying) if this really is the right folder."
if has "$OTHER_MARKER"; then
  refuse "${SITE_DIR} has both ${MARKER} and ${OTHER_MARKER}; a folder can only be one or the other."
fi
echo "OK: ${SITE_DIR} is marked as the ${BUILD} folder. Uploading the ${BUILD} build."

ASSETS_DIR="${SITE_DIR}/_astro"

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
