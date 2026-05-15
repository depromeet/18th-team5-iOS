#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"
source "${script_dir}/common.sh"

cd "$repo_root"

ensure_gcloud_ready

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

archive_path="${tmp_dir}/Secrets.tar.gz"
extract_dir="${tmp_dir}/extracted"

gcloud secrets versions access latest \
    --project="$project_id" \
    --secret="$secrets_archive_name" \
    --out-file="$archive_path"

mkdir -p "$extract_dir"
tar -xzf "$archive_path" -C "$extract_dir"

if [[ ! -d "${extract_dir}/Secrets" ]]; then
    echo "오류: '${secrets_archive_name}' archive에 Secrets/ 폴더가 없습니다." >&2
    exit 1
fi

rm -rf Secrets
mv "${extract_dir}/Secrets" Secrets

echo "Secrets/ 폴더를 Google Secret Manager에서 복원했습니다."
