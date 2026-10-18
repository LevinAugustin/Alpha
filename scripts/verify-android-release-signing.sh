#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
policy_file="$repo_root/android/signing-policy.properties"
expected_package=$(
  sed -n 's/^productionApplicationId=//p' "$policy_file" | head -n 1 | tr -d '[:space:]'
)
expected_sha256=$(
  sed -n 's/^productionCertificateSha256=//p' "$policy_file" | head -n 1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]'
)

if [[ -z "$expected_package" ]]; then
  echo "Missing productionApplicationId in $policy_file" >&2
  exit 2
fi

if [[ -z "$expected_sha256" ]]; then
  echo "Missing productionCertificateSha256 in $policy_file" >&2
  exit 2
fi

find_tool() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return
  fi

  local sdk
  for sdk in "${ANDROID_SDK_ROOT:-}" "${ANDROID_HOME:-}" /opt/android-sdk "$HOME/android-sdk"; do
    [[ -n "$sdk" && -d "$sdk" ]] || continue
    find "$sdk" -type f -name "$name" -print | sort -V | tail -n 1
  done | tail -n 1
}

apksigner_bin=$(find_tool apksigner)
if [[ -z "$apksigner_bin" ]]; then
  echo "Could not find apksigner" >&2
  exit 2
fi

aapt_bin=$(find_tool aapt)
if [[ -z "$aapt_bin" ]]; then
  echo "Could not find aapt" >&2
  exit 2
fi

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <apk> [apk ...]" >&2
  exit 2
fi

for apk in "$@"; do
  [[ -f "$apk" ]] || {
    echo "APK not found: $apk" >&2
    exit 2
  }

  "$apksigner_bin" verify --print-certs "$apk"

  actual_sha256=$(
    "$apksigner_bin" verify --print-certs "$apk" \
      | sed -n 's/.*SHA-256 digest: //p' \
      | head -n 1 \
      | tr -d '[:space:]' \
      | tr -d ':' \
      | tr '[:upper:]' '[:lower:]'
  )
  if [[ "$actual_sha256" != "$expected_sha256" ]]; then
    echo "Wrong signing certificate for $apk" >&2
    echo "  expected: $expected_sha256" >&2
    echo "  actual:   ${actual_sha256:-<missing>}" >&2
    exit 1
  fi

  package=$(
    "$aapt_bin" dump badging "$apk" \
      | sed -n 's/^package: name='"'"'\([^'"'"']*\)'"'"'.*/\1/p' \
      | head -n 1
  )
  if [[ "$package" != "$expected_package" ]]; then
    echo "Wrong application id for $apk" >&2
    echo "  expected: $expected_package" >&2
    echo "  actual:   ${package:-<missing>}" >&2
    exit 1
  fi

  echo "Verified signed APK: $apk ($package)"
done
