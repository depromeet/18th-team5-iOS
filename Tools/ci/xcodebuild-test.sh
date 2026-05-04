#!/usr/bin/env bash
set -euo pipefail

scheme="$1"
destination="$2"
result_bundle_path="$3"

mkdir -p "$(dirname "$result_bundle_path")"

xcodebuild test \
    -workspace Peaktime.xcworkspace \
    -scheme "$scheme" \
    -configuration DebugDev \
    -destination "$destination" \
    -resultBundlePath "$result_bundle_path"
