#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_ROOT/bin/rs-guard.manifest"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Missing rs-guard manifest: $MANIFEST" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$MANIFEST"

: "${RS_GUARD_VERSION:?RS_GUARD_VERSION is required in bin/rs-guard.manifest}"
: "${RS_GUARD_ASSET:?RS_GUARD_ASSET is required in bin/rs-guard.manifest}"
: "${RS_GUARD_SHA256:?RS_GUARD_SHA256 is required in bin/rs-guard.manifest}"

INSTALL_DIR="${RS_GUARD_INSTALL_DIR:-$REPO_ROOT}"
OUTPUT_NAME="${RS_GUARD_OUTPUT_NAME:-rs-guard}"
ASSET_PATH="$INSTALL_DIR/$RS_GUARD_ASSET"
OUTPUT_PATH="$INSTALL_DIR/$OUTPUT_NAME"
CURL_OPTS=(--fail --silent --show-error --location --retry 3 --retry-delay 2)

mkdir -p "$INSTALL_DIR"

BASE_URL="https://github.com/nebulaideas/rs-guard/releases/download/${RS_GUARD_VERSION}"

echo "Downloading rs-guard ${RS_GUARD_VERSION} (${RS_GUARD_ASSET})..."
# Release asset is a pre-built ELF binary (not a .tar.gz/.zip). No extraction step needed.
# Verified in CI: download → sha256sum -c → rs-guard --version → review completes successfully.
curl "${CURL_OPTS[@]}" -o "$ASSET_PATH" "${BASE_URL}/${RS_GUARD_ASSET}"
curl "${CURL_OPTS[@]}" -o "${ASSET_PATH}.sha256" "${BASE_URL}/${RS_GUARD_ASSET}.sha256"

chmod +x "$ASSET_PATH"

(
  cd "$INSTALL_DIR"
  sha256sum -c "${RS_GUARD_ASSET}.sha256"
)

ACTUAL_SHA256="$(awk '{ print $1 }' "$INSTALL_DIR/${RS_GUARD_ASSET}.sha256")"
if [[ "$ACTUAL_SHA256" != "$RS_GUARD_SHA256" ]]; then
  echo "Pinned manifest checksum does not match release checksum file." >&2
  echo "Expected (manifest): $RS_GUARD_SHA256" >&2
  echo "Actual (release):    $ACTUAL_SHA256" >&2
  exit 1
fi

if [[ "$ASSET_PATH" != "$OUTPUT_PATH" ]]; then
  cp "$ASSET_PATH" "$OUTPUT_PATH"
  chmod +x "$OUTPUT_PATH"
fi

if [[ "$(uname -s)" == "Linux" ]]; then
  "$OUTPUT_PATH" --version
else
  echo "Checksum verified for $OUTPUT_PATH (Linux binary; execution skipped on non-Linux host)."
fi

echo "rs-guard installed at $OUTPUT_PATH"
