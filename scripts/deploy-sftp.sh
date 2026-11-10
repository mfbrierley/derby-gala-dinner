#!/usr/bin/env bash
#
# Upload the built site (dist/) to the IONOS web space over SFTP, sending only what changed.
# Used by the GitHub Actions workflows in .github/workflows/; can also be run by hand:
#
#   IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD=... scripts/deploy-sftp.sh /new-private
#
# THE WEB SPACE IS SHARED WITH OTHER CLIENTS' SITES (one folder each at the top level). This script
# must never write to, or delete from, anything outside the Derby Gala Dinner folders.
#
# The login it's given must be the restricted SFTP account IONOS limits to the derbygaladinner
# folder: that account sees the folder as "/" (live site) with the test copy in "/new-private".
# The server itself stops that account reaching anything else. On top of that, all checked before
# anything is written:
#
#   0. The login's top folder ("/") must hold the .dgd-deploy-live permission file, i.e. it really
#      is the Derby Gala Dinner folder. A login that sees the whole web space (all clients' folders
#      at its top) has no such file there, so it's refused, for live and test deploys alike.
#   1. Fixed folders. The only folders this script will ever upload to are listed below
#      (LIVE_DIR, TEST_DIR). They're written into this file, not taken from settings, so no
#      workflow variable or secret can point it anywhere else. Anything else is refused before
#      connecting.
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
LIVE_DIR="/"
TEST_DIR="/new-private"
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

# Exact matches only (a trailing slash on the test folder is fine).
case "$REMOTE_DIR" in
  "$LIVE_DIR") SITE_DIR="$LIVE_DIR" ;;
  "$TEST_DIR" | "$TEST_DIR/") SITE_DIR="$TEST_DIR" ;;
  *) refuse "'${REMOTE_DIR}' isn't one of the two folders this script may write to: ${LIVE_DIR} (live) or ${TEST_DIR} (test), as seen by the restricted Derby Gala Dinner login." ;;
esac

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
if [ "$BUILD" = "live" ]; then WANT_DIR="$LIVE_DIR"; else WANT_DIR="$TEST_DIR"; fi
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

# ---- 0 + 3. Permission files, checked over a read-only connection -----------------------------
# Lists the login's top folder and the target folder (names only), changing nothing.
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

echo "Checking the login's top folder on ${IONOS_SFTP_HOST} (read-only) for ${LIVE_MARKER}"
if ! ROOT_LISTING=$(read_listing "$LIVE_DIR"); then
  echo "$ROOT_LISTING" >&2
  refuse "couldn't read the login's top folder (wrong login or password?)."
fi
has "$ROOT_LISTING" "$LIVE_MARKER" ||
  refuse "the login's top folder has no ${LIVE_MARKER} file, so it isn't the Derby Gala Dinner folder. GitHub must use the SFTP account IONOS restricts to the derbygaladinner folder, and that folder needs the empty ${LIVE_MARKER} file (see README > Deploying)."
if has "$ROOT_LISTING" "$TEST_MARKER"; then
  refuse "the login's top folder has both ${LIVE_MARKER} and ${TEST_MARKER}; it can only be the live folder."
fi

if [ "$BUILD" = "test" ]; then
  echo "Checking ${TEST_DIR} (read-only) for ${TEST_MARKER}"
  if ! TEST_LISTING=$(read_listing "$TEST_DIR"); then
    echo "$TEST_LISTING" >&2
    refuse "couldn't read ${TEST_DIR} (does the folder exist?)."
  fi
  has "$TEST_LISTING" "$TEST_MARKER" ||
    refuse "${TEST_DIR} has no ${TEST_MARKER} file, so it isn't marked as the test folder. Create that empty file there by hand (see README > Deploying) if this really is the right folder."
  if has "$TEST_LISTING" "$LIVE_MARKER"; then
    refuse "${TEST_DIR} has both ${TEST_MARKER} and ${LIVE_MARKER}; it can only be the test folder."
  fi
fi
echo "OK: this is the Derby Gala Dinner login and ${SITE_DIR} is marked as the ${BUILD} folder. Uploading the ${BUILD} build."

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
