#!/usr/bin/env bash
set -euo pipefail

destination="$1"
failed=0

test_schemes=(
    CoreTests
    DataTests
    DomainTests
    PresentationTests
)

for scheme in "${test_schemes[@]}"; do
    if ! Tools/ci/xcodebuild-test.sh "$scheme" "$destination" "TestResults/${scheme}.xcresult"; then
        failed=1
    fi
done

exit "$failed"
