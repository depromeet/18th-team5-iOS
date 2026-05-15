#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"
source "${script_dir}/common.sh"

cd "$repo_root"

ensure_gcloud_ready

if [[ ! -d "Secrets" ]]; then
    echo "오류: 로컬 Secrets/ 폴더가 없어 push를 중단합니다." >&2
    echo "실행 명령어: make pull-secrets" >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

local_archive_path="${tmp_dir}/local-Secrets.tar.gz"
latest_archive_path="${tmp_dir}/latest-Secrets.tar.gz"
latest_extract_dir="${tmp_dir}/latest"
encoded_archive_path="${tmp_dir}/Secrets.tar.gz.base64"

tar --exclude='.DS_Store' \
    -czf "$local_archive_path" \
    Secrets

base64_encode_file "$local_archive_path" "$encoded_archive_path"

encoded_archive_size="$(wc -c < "$encoded_archive_path" | tr -d ' ')"
if [[ "$encoded_archive_size" -gt 49152 ]]; then
    echo "오류: GitHub Actions Secret 크기 제한(48KB)을 초과했습니다. 현재 크기: ${encoded_archive_size} bytes" >&2
    exit 1
fi

push_github_actions_secret() {
    ensure_gh_ready
    gh secret set "$github_actions_secret_name" \
        --repo "$github_repo" \
        < "$encoded_archive_path"
    echo "GitHub Actions Secret '${github_actions_secret_name}'를 갱신했습니다."
}

if ! gcloud secrets describe "$secrets_archive_name" >/dev/null 2>&1; then
    echo "Secret Manager에 '${secrets_archive_name}'가 없습니다."
    if ! confirm "로컬 Secrets/ 폴더로 '${secrets_archive_name}'를 생성하고 GitHub Actions Secret도 갱신할까요?"; then
        echo "push를 취소했습니다."
        exit 0
    fi

    gcloud secrets create "$secrets_archive_name" \
        --replication-policy="automatic" \
        --data-file="$local_archive_path"
    echo "Secrets archive를 Google Secret Manager에 생성했습니다."

    push_github_actions_secret
    exit 0
fi

if ! gcloud secrets versions access latest \
    --secret="$secrets_archive_name" \
    --out-file="$latest_archive_path"; then
    echo "오류: Secret Manager에서 '${secrets_archive_name}' latest 버전을 읽지 못했습니다." >&2
    exit 1
fi

mkdir -p "$latest_extract_dir"
tar -xzf "$latest_archive_path" -C "$latest_extract_dir"

if [[ ! -d "${latest_extract_dir}/Secrets" ]]; then
    echo "오류: Secret Manager의 '${secrets_archive_name}' archive에 Secrets/ 폴더가 없습니다." >&2
    exit 1
fi

local_hash="$(directory_hash Secrets)"
latest_hash="$(directory_hash "${latest_extract_dir}/Secrets")"

if [[ "$local_hash" == "$latest_hash" ]]; then
    echo "Google Secret Manager에 push할 secret 변경사항이 없습니다."
    if confirm "GitHub Actions Secret '${github_actions_secret_name}'를 현재 로컬 Secrets/로 갱신할까요?"; then
        push_github_actions_secret
    fi
    exit 0
fi

echo "로컬 Secrets/ 폴더가 Secret Manager latest와 다릅니다."
echo "  - Secrets/ -> ${secrets_archive_name}"

if ! confirm "로컬 Secrets/ 폴더를 Google Secret Manager의 새 버전으로 업로드하고 GitHub Actions Secret도 갱신할까요?"; then
    echo "push를 취소했습니다."
    exit 0
fi

gcloud secrets versions add "$secrets_archive_name" \
    --data-file="$local_archive_path"
echo "Secrets archive를 Google Secret Manager에 업로드했습니다."

push_github_actions_secret
