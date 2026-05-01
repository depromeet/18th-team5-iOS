#!/usr/bin/env bash
set -euo pipefail

output_file="${GITHUB_OUTPUT:-}"
available_simulators_json="$(mktemp)"
trap 'rm -f "$available_simulators_json"' EXIT

xcodebuild -version
xcrun simctl list devices available

xcrun simctl list devices available --json > "$available_simulators_json"

destination="$(
    AVAILABLE_SIMULATORS_JSON="$available_simulators_json" python3 <<'PY'
import json
import os
import re
import sys

with open(os.environ["AVAILABLE_SIMULATORS_JSON"]) as file:
    devices_by_runtime = json.load(file).get("devices", {})

candidates = []

for runtime, devices in devices_by_runtime.items():
    match = re.search(r"iOS-(\d+)-(\d+)", runtime)
    if not match:
        continue

    runtime_version = tuple(map(int, match.groups()))
    for index, device in enumerate(devices):
        if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
            candidates.append((runtime_version, -index, device["name"]))

if not candidates:
    sys.exit("No available iPhone simulator found")

candidates.sort(reverse=True)
_, _, device_name = candidates[0]
print(f"platform=iOS Simulator,name={device_name},OS=latest")
PY
)"

if [[ -n "$output_file" ]]; then
    echo "destination=${destination}" >> "$output_file"
fi

echo "Selected simulator destination: ${destination}"
