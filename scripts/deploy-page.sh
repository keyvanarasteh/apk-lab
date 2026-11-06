#!/usr/bin/env bash
# deploy-page.sh — publish the dashboard (Astro, static) to GitHub Pages from your machine.
#
# No CI, no workflow files, no paid runners: the site is built locally, committed to an
# orphan `gh-pages` branch and force-pushed with `gh`. GitHub Pages then serves that branch.
# The site opens on the firewall-lab page (the root redirects to /firewall/).
#
# Usage:
#   scripts/deploy-page.sh                      build + deploy to this repo's Pages
#   scripts/deploy-page.sh --dry-run            build + stage, print the folder, push nothing
#   scripts/deploy-page.sh --repo OWNER/NAME    deploy to another repo (short name = short URL,
#                                               e.g. keyvanarasteh/fw -> keyvanarasteh.github.io/fw/)
#   scripts/deploy-page.sh --branch gh-pages    target branch (default gh-pages)
#   scripts/deploy-page.sh --landing PATH       where / redirects (default firewall/, "" = keep host page)
#   scripts/deploy-page.sh --no-build           reuse the previous build (dashboard/build-pages.raw)
#   scripts/deploy-page.sh -h|--help
#
# Needs: node + npm, git, gh (logged in with push access: `gh auth login`).
set -euo pipefail

REPO=""; BRANCH="gh-pages"; LANDING="firewall/"; DRY=0; BUILD=1
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?--repo needs OWNER/NAME}"; shift 2 ;;
    --branch) BRANCH="${2:?--branch needs a name}"; shift 2 ;;
    --landing) LANDING="${2-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --no-build) BUILD=0; shift ;;
    -h|--help) sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (see --help)" >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/dashboard"
RAW="$APP/build-pages.raw"      # plain astro build (gitignored, see dashboard/.gitignore)
OUT="$APP/build-pages"          # post-processed site that gets published (gitignored)

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }; }
need node; need npm; need git; need gh
gh auth status >/dev/null 2>&1 || { echo "gh is not logged in: run 'gh auth login'" >&2; exit 1; }

[ -n "$REPO" ] || REPO="$(cd "$ROOT" && gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO%%/*}"; NAME="${REPO##*/}"
# <owner>.github.io repos are served from the domain root, every other repo from /<name>/
if [ "$(echo "$NAME" | tr 'A-Z' 'a-z')" = "$(echo "$OWNER" | tr 'A-Z' 'a-z').github.io" ]; then
  BASE=""; URL="https://$NAME/"
else
  BASE="/$NAME"; URL="https://$(echo "$OWNER" | tr 'A-Z' 'a-z').github.io/$NAME/"
fi
echo "==> target  $REPO ($BRANCH)  ->  $URL"

# ---- 1. build the static site with the right base path ----
if [ "$BUILD" = 1 ]; then
  [ -d "$APP/node_modules" ] || (cd "$APP" && npm ci)
  rm -rf "$RAW"
  echo "==> astro build (base='${BASE:-/}')"
  (cd "$APP" && SITE_BASE="$BASE" npx --no-install astro build --outDir "$RAW")
fi
[ -f "$RAW/index.html" ] || { echo "no build in $RAW (run without --no-build)" >&2; exit 1; }
rm -rf "$OUT"; cp -R "$RAW" "$OUT"          # post-process a copy so re-runs start clean

# ---- 2. prefix the hard-coded absolute links with the base path ----
# Astro's `base` already fixes assets and <a> links it renders; the React views also contain
# literal "/firewall/"-style routes. Rewrite those in the build (idempotent: already-prefixed
# paths start with /<name>/ and no longer match). /api is left alone: there is no backend here.
if [ -n "$BASE" ]; then
  echo "==> prefixing route literals with $BASE"
  export BASE
  find "$OUT" -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' \) -print0 |
    xargs -0 perl -pi -e '
      s!(["\x27`(=])/(tr|firewall|android|labs|jobs|contribute|legal|apk-lab|favicon\.svg|_astro)(?=[/"\x27`#?)\s>])!$1$ENV{BASE}/$2!g;
      s{(href=["\x27]|href:\s*["\x27])/(?=["\x27])}{$1$ENV{BASE}/}g;
    '
fi

# ---- 3. landing page + Pages housekeeping ----
touch "$OUT/.nojekyll"                      # keep the _astro/ folder (Jekyll skips "_" dirs)
if [ -n "$LANDING" ]; then
  mv "$OUT/index.html" "$OUT/host.html"     # the host overview needs the local console API
  cat > "$OUT/index.html" <<HTML
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=${BASE}/${LANDING}">
<link rel="canonical" href="${URL}${LANDING}">
<title>firewall-lab</title>
<script>location.replace("${BASE}/${LANDING}" + location.hash);</script>
</head><body><a href="${BASE}/${LANDING}">firewall-lab</a></body></html>
HTML
fi

if [ "$DRY" = 1 ]; then
  echo "==> dry run: staged in $OUT ($(find "$OUT" -type f | wc -l | tr -d ' ') files), nothing pushed"
  exit 0
fi

# ---- 4. commit as a single orphan commit and force-push the branch ----
SRC_SHA="$(cd "$ROOT" && git rev-parse --short HEAD)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -R "$OUT/." "$TMP/"
(
  cd "$TMP"
  git init -q -b "$BRANCH"
  git add -A
  git -c user.name="$(git -C "$ROOT" config user.name || echo deploy)" \
      -c user.email="$(git -C "$ROOT" config user.email || echo deploy@localhost)" \
      commit -q -m "deploy: dashboard @ $SRC_SHA ($(date -u +%Y-%m-%dT%H:%MZ))"
  echo "==> pushing $BRANCH"
  git -c credential.helper= -c credential.helper='!gh auth git-credential' \
      push -q --force "https://github.com/$REPO.git" "$BRANCH"
)

# ---- 5. make sure Pages serves that branch (no-op when already set) ----
echo "==> enabling GitHub Pages ($BRANCH, /)"
gh api -X POST "repos/$REPO/pages" -f "source[branch]=$BRANCH" -f "source[path]=/" >/dev/null 2>&1 ||
  gh api -X PUT "repos/$REPO/pages" -f "source[branch]=$BRANCH" -f "source[path]=/" >/dev/null 2>&1 || true

# ---- 6. wait for the (free, GitHub-run) Pages build ----
for i in $(seq 1 30); do
  st="$(gh api "repos/$REPO/pages/builds/latest" -q .status 2>/dev/null || echo unknown)"
  [ "$st" = "built" ] && { echo "==> live: $URL"; exit 0; }
  [ "$st" = "errored" ] && { echo "Pages build errored: gh api repos/$REPO/pages/builds/latest" >&2; exit 1; }
  sleep 5
done
echo "==> pushed; Pages is still building. It will appear at $URL"
