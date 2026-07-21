#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_ROOT/bin/rs-guard.manifest"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Missing rs-guard manifest: $MANIFEST" >&2
  exit 1
fi

read_manifest_value() {
  local key="$1"
  local raw
  raw="$(sed -n "s/^${key}=\"\(.*\)\"$/\1/p" "$MANIFEST" || true)"
  printf '%s' "$raw"
}

RS_GUARD_VERSION="$(read_manifest_value RS_GUARD_VERSION)"
RS_GUARD_ASSET="$(read_manifest_value RS_GUARD_ASSET)"
RS_GUARD_SHA256="$(read_manifest_value RS_GUARD_SHA256)"

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
# Verified in CI: download → sha256 vs manifest pin → rs-guard --version → review completes.
curl "${CURL_OPTS[@]}" -o "$ASSET_PATH" "${BASE_URL}/${RS_GUARD_ASSET}"

chmod +x "$ASSET_PATH"

# Verify against the manifest-pinned checksum only. The previous flow also
# downloaded a .sha256 sidecar from the same release and ran `sha256sum -c`
# against it — but if the release is compromised, both the binary and the
# sidecar can be replaced together, making that step redundant. The manifest
# pin (committed to this repo) is the strong defense.
ACTUAL_SHA256="$(sha256sum "$ASSET_PATH" | awk '{ print $1 }')"
if [[ "$ACTUAL_SHA256" != "$RS_GUARD_SHA256" ]]; then
  echo "Pinned manifest checksum does not match downloaded binary." >&2
  echo "Expected (manifest): $RS_GUARD_SHA256" >&2
  echo "Actual (download):   $ACTUAL_SHA256" >&2
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
