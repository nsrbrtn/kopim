#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "" ]]; then
  echo "Usage: $0 <device-id> [output-path] [flavor]" >&2
  exit 1
fi

DEVICE_ID="$1"
OUTPUT_PATH="${2:-perf/sksl_warmup.json}"
FLAVOR_ARG="${3:-${FLAVOR:-}}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_DIR"

FLAVOR_FLAGS=()
if [[ -n "$FLAVOR_ARG" ]]; then
  FLAVOR_FLAGS=(--flavor "$FLAVOR_ARG")
fi

flutter run \
  --profile \
  --cache-sksl \
  --purge-persistent-cache \
  -d "$DEVICE_ID" \
  "${FLAVOR_FLAGS[@]}" \
  --trace-skia

echo "Captured SkSL shaders. Building release bundle with warm-up data..."

flutter build apk \
  --bundle-sksl-path "$OUTPUT_PATH" \
  "${FLAVOR_FLAGS[@]}"

echo "SkSL bundle written to $OUTPUT_PATH"
