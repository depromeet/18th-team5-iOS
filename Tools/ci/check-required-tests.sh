#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${1:-origin/develop}"

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    echo "::warning::Base ref '$BASE_REF' was not found. Skipping required test file check."
    exit 0
fi

missing_count=0

emit_missing_test_warning() {
    local source_file="$1"
    local test_file="$2"

    echo "::warning file=${source_file}::Missing test file: ${test_file}"
    missing_count=$((missing_count + 1))
}

while IFS= read -r source_file; do
    if [[ ! -f "$source_file" ]]; then
        continue
    fi

    case "$source_file" in
        Projects/Presentation/Sources/*.swift|Projects/Presentation/Sources/**/*.swift)
            if grep -q '@Reducer' "$source_file"; then
                file_name="$(basename "$source_file" .swift)"
                test_file="Projects/Presentation/Tests/${file_name}Tests.swift"

                if [[ ! -f "$test_file" ]]; then
                    emit_missing_test_warning "$source_file" "$test_file"
                fi
            fi
            ;;
        Projects/Data/Sources/Repository/*RepositoryImpl.swift)
            file_name="$(basename "$source_file" .swift)"
            repository_name="${file_name%Impl}"
            test_file="Projects/Data/Tests/${repository_name}Tests.swift"

            if [[ ! -f "$test_file" ]]; then
                emit_missing_test_warning "$source_file" "$test_file"
            fi
            ;;
    esac
done < <(git diff --name-only --diff-filter=AM "$BASE_REF"...HEAD -- '*.swift')

if [[ "$missing_count" -gt 0 ]]; then
    echo "Required test file check completed with ${missing_count} warning(s)."
else
    echo "Required test file check completed without warnings."
fi

exit 0
