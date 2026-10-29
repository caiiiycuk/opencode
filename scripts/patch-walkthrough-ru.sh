#!/usr/bin/env bash
# Add Russian to the OpenChamber walkthrough review language picker.
#
# OpenChamber keeps the walkthrough language in two places:
#   - server: node_modules/@openchamber/web/server/lib/walkthrough/languages.js
#     inside resources/app.asar (LANGUAGE_NAMES decides what the prompt says);
#   - client: resources/web-dist/assets/useWalkthroughReview-*.js, where the
#     picker takes `locales` and `label` from the shared i18n hook.
# The UI locale list itself is left alone: there is no Russian dictionary, so
# adding `ru` there would break the interface language switcher.
#
# Re-run after every OpenChamber update: the installer overwrites /opt/OpenChamber.
set -euo pipefail

APP_DIR="${OPENCHAMBER_DIR:-/opt/OpenChamber}"
ASAR="$APP_DIR/resources/app.asar"
ASSETS="$APP_DIR/resources/web-dist/assets"
LANGUAGES_JS="node_modules/@openchamber/web/server/lib/walkthrough/languages.js"
LABEL="Russian"

[ -f "$ASAR" ] || { echo "not found: $ASAR" >&2; exit 1; }
[ -d "$ASSETS" ] || { echo "not found: $ASSETS" >&2; exit 1; }
command -v npx >/dev/null || { echo "npx is required (@electron/asar is run through it)" >&2; exit 1; }

asar() { npx -y @electron/asar "$@"; }
SUDO=""
[ -w "$APP_DIR/resources" ] || SUDO=sudo

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- server: LANGUAGE_NAMES in app.asar ---
(cd "$TMP" && asar extract-file "$ASAR" "$LANGUAGES_JS")
if grep -q "ru: 'Russian'" "$TMP/languages.js"; then
  echo "app.asar: already patched"
else
  grep -q "^  he: 'Hebrew',$" "$TMP/languages.js" || { echo "app.asar: $LANGUAGES_JS has unexpected layout, patch aborted" >&2; exit 1; }
  asar extract "$ASAR" "$TMP/app"
  sed -i "s/^  he: 'Hebrew',$/  he: 'Hebrew',\n  ru: 'Russian',/" "$TMP/app/$LANGUAGES_JS"
  # Reproduce the original unpacked set (native .node/.so and git helpers must stay outside the archive):
  # directories go through --unpack-dir (relative paths), single files through --unpack (matched against absolute paths).
  ORIGINAL_LIST="$(asar list --is-pack "$ASAR")"
  UNPACK_DIRS="$(printf '%s\n' "$ORIGINAL_LIST" | sed -n 's|^unpack : /||p' | while read -r entry; do [ -d "$TMP/app/$entry" ] || continue; printf '%s\n' "$entry"; done | paste -sd, -)"
  UNPACK_FILES="$(printf '%s\n' "$ORIGINAL_LIST" | sed -n 's|^unpack : /||p' | while read -r entry; do [ -f "$TMP/app/$entry" ] || continue; printf '**/%s\n' "$entry"; done | paste -sd, -)"
  asar pack "$TMP/app" "$TMP/app.asar" --unpack-dir "{$UNPACK_DIRS}" --unpack "{$UNPACK_FILES}"
  if ! diff <(printf '%s\n' "$ORIGINAL_LIST" | LC_ALL=C sort) <(asar list --is-pack "$TMP/app.asar" | LC_ALL=C sort) >/dev/null; then
    echo "app.asar: repacked archive differs in file list or unpacked set, patch aborted" >&2
    exit 1
  fi
  [ -f "$ASAR.orig" ] || $SUDO cp -p "$ASAR" "$ASAR.orig"
  $SUDO install -m 644 "$TMP/app.asar" "$ASAR"
  echo "app.asar: patched (backup: $ASAR.orig)"
fi

# --- client: language picker in the walkthrough chunk ---
# Dictionaries hold the key as `"...menuLabel":`; only the picker code calls `t("...menuLabel")`.
CHUNK="$(grep -lF '("walkthrough.language.menuLabel")' "$ASSETS"/*.js)"
[ "$(printf '%s\n' "$CHUNK" | wc -l)" -eq 1 ] || { echo "web-dist: expected exactly one chunk with the picker, got: $CHUNK" >&2; exit 1; }
if grep -q 'ocRuLocales' "$CHUNK"; then
  echo "web-dist: already patched ($(basename "$CHUNK"))"
else
  cp "$CHUNK" "$TMP/chunk.js"
  # Each pattern must match exactly once; a different count means the build layout changed.
  for pattern in '\{t:\w+,locales:\w+,label:\w+\}=\w+\(\)' '\{locale:\w+,locales:\w+\}=\w+\(\)' '\{t:\w+,label:\w+\}=\w+\(\)'; do
    count="$(grep -oP "$pattern" "$TMP/chunk.js" | wc -l)"
    [ "$count" -eq 1 ] || { echo "web-dist: pattern $pattern matched $count times, patch aborted" >&2; exit 1; }
  done
  perl -pi -e '
    s/\{t:(\w+),locales:(\w+),label:(\w+)\}=(\w+)\(\)/{t:$1,locales:ocRuLocales,label:ocRuLabel}=$4(),$2=[...ocRuLocales,"ru"],$3=ocRuX=>ocRuX==="ru"?"'"$LABEL"'":ocRuLabel(ocRuX)/;
    s/\{locale:(\w+),locales:(\w+)\}=(\w+)\(\)/{locale:$1,locales:ocRuLocales}=$3(),$2=[...ocRuLocales,"ru"]/;
    s/\{t:(\w+),label:(\w+)\}=(\w+)\(\)/{t:$1,label:ocRuLabel}=$3(),$2=ocRuX=>ocRuX==="ru"?"'"$LABEL"'":ocRuLabel(ocRuX)/;
  ' "$TMP/chunk.js"
  node --input-type=module --check < "$TMP/chunk.js"
  [ -f "$CHUNK.orig" ] || $SUDO cp -p "$CHUNK" "$CHUNK.orig"
  $SUDO install -m 644 "$TMP/chunk.js" "$CHUNK"
  echo "web-dist: patched $(basename "$CHUNK") (backup: $CHUNK.orig)"
fi

echo "done: restart OpenChamber to pick up the change"
