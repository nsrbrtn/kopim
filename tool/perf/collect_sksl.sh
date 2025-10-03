#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "" ]]; then
  echo "Usage: $0 <device-id> [output-path]" >&2
  exit 1
fi

DEVICE_ID="$1"
OUTPUT_PATH="${2:-perf/sksl_warmup.json}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_DIR"

flutter run \
  --profile \
  --cache-sksl \
  --purge-persistent-cache \
  -d "$DEVICE_ID" \
  --trace-skia

echo "Captured SkSL shaders. Building release bundle with warm-up data..."

flutter build apk --bundle-sksl-path "$OUTPUT_PATH"

echo "SkSL bundle written to $OUTPUT_PATH"
