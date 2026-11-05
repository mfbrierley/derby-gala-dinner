#!/usr/bin/env bash
#
# Upload the built site (dist/) to the IONOS web space over SFTP, sending only what changed.
# Used by the GitHub Actions workflows in .github/workflows/; can also be run by hand:
#
#   IONOS_SFTP_HOST=... IONOS_SFTP_USER=... IONOS_SFTP_PASSWORD=... scripts/deploy-sftp.sh /new-private
#
# How it decides what to send:
# - dist/_astro/ holds the images, video, scripts and styles. Every file there is named after its
#   contents, so a file that already exists on the server is identical: only missing ones are sent.
# - Everything else (the pages, .htaccess, robots.txt, favicon) is small and always sent.
# - Order matters: new _astro files go up first, then the pages that use them, and only then are
#   _astro files the new pages no longer use removed. A visitor never gets a page whose files
#   aren't there yet.
# Nothing outside the target folder is touched (e.g. a live upload to / leaves /new-private/ alone).

set -euo pipefail

REMOTE_DIR="${1:?usage: scripts/deploy-sftp.sh <remote folder, e.g. / or /new-private>}"
: "${IONOS_SFTP_HOST:?IONOS_SFTP_HOST is not set}"
: "${IONOS_SFTP_USER:?IONOS_SFTP_USER is not set}"
: "${IONOS_SFTP_PASSWORD:?IONOS_SFTP_PASSWORD is not set}"
PORT="${IONOS_SFTP_PORT:-22}"

if [ ! -f dist/index.html ] || [ ! -d dist/_astro ]; then
  echo "dist/ isn't built yet: run npm run build (live) or npm run build:test (test copy) first." >&2
  exit 1
fi

# "/new-private/" -> "/new-private", "/" stays "/"
SITE_DIR="${REMOTE_DIR%/}"
SITE_DIR="${SITE_DIR:-/}"
ASSETS_DIR="${SITE_DIR%/}/_astro"

echo "Uploading dist/ to ${IONOS_SFTP_HOST}:${SITE_DIR}"

# The password is passed through the environment, never on the command line.
export LFTP_PASSWORD="$IONOS_SFTP_PASSWORD"

lftp <<EOF
set cmd:fail-exit yes
set net:max-retries 4
set net:reconnect-interval-base 5
set net:timeout 60
set sftp:auto-confirm yes
open --env-password -u "${IONOS_SFTP_USER}" -p ${PORT} sftp://${IONOS_SFTP_HOST}
mkdir -p -f "${ASSETS_DIR}"
echo "1/3 New images, video, scripts and styles (_astro)"
mirror --reverse --only-missing --no-perms --parallel=4 --verbose=1 dist/_astro "${ASSETS_DIR}"
echo "2/3 Pages and settings"
mirror --reverse --no-perms --parallel=4 --verbose=1 --exclude-glob _astro/ dist "${SITE_DIR}"
echo "3/3 Removing _astro files the new pages no longer use"
mirror --reverse --only-missing --delete --no-perms --verbose=1 dist/_astro "${ASSETS_DIR}"
bye
EOF

echo "Done."
