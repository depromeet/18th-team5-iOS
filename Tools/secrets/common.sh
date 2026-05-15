#!/usr/bin/env bash

project_id="peaktime-b0f09"
secrets_archive_name="secrets"
github_repo="depromeet/18th-team5-iOS"
github_actions_secret_name="SECRETS_ARCHIVE_BASE64"

activate_gcloud() {
    if command -v gcloud >/dev/null 2>&1; then
        return 0
    fi

    local candidates=(
        "/opt/homebrew/bin/gcloud"
        "/usr/local/bin/gcloud"
        "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gcloud"
        "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gcloud"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            export PATH="$(dirname "$candidate"):$PATH"
            hash -r
            return 0
        fi
    done

    return 1
}

activate_gh() {
    if command -v gh >/dev/null 2>&1; then
        return 0
    fi

    local candidates=(
        "/opt/homebrew/bin/gh"
        "/usr/local/bin/gh"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            export PATH="$(dirname "$candidate"):$PATH"
            hash -r
            return 0
        fi
    done

    return 1
}

confirm() {
    local prompt="$1"
    local answer

    read -r -p "${prompt} [y/N] " answer
    case "$answer" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

base64_encode_file() {
    local input_path="$1"
    local output_path="$2"

    base64 < "$input_path" | tr -d '\n' > "$output_path"
}

directory_hash() {
    local dir="$1"

    find "$dir" -type f ! -name ".DS_Store" -print \
        | LC_ALL=C sort \
        | while IFS= read -r file; do
            local relative_path
            local file_hash

            relative_path="${file#"$dir"/}"
            file_hash="$(shasum -a 256 "$file" | awk '{print $1}')"
            printf '%s  %s\n' "$file_hash" "$relative_path"
        done \
        | shasum -a 256 \
        | awk '{print $1}'
}

ensure_gh_ready() {
    if ! activate_gh; then
        echo "GitHub CLI(gh)가 설치되어 있지 않습니다."
        if confirm "Homebrew로 gh를 설치할까요?"; then
            if ! command -v brew >/dev/null 2>&1; then
                echo "오류: Homebrew가 설치되어 있지 않아 gh를 자동 설치할 수 없습니다." >&2
                echo "Homebrew 설치: https://brew.sh" >&2
                exit 1
            fi
            brew install gh
            if ! activate_gh; then
                echo "오류: gh 설치 후에도 gh 명령어를 찾을 수 없습니다." >&2
                echo "터미널을 재시작한 뒤 다시 make push-secrets를 실행해 주세요." >&2
                exit 1
            fi
        else
            echo "오류: gh 설치가 필요합니다." >&2
            echo "설치 명령어: brew install gh" >&2
            exit 1
        fi
    fi

    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        echo "GitHub CLI에 로그인되어 있지 않습니다."
        if confirm "GitHub 계정으로 로그인할까요?"; then
            gh auth login --hostname github.com
            if ! gh auth status --hostname github.com >/dev/null 2>&1; then
                echo "오류: gh 로그인 완료 상태를 확인할 수 없습니다." >&2
                echo "실행 명령어: gh auth login --hostname github.com" >&2
                exit 1
            fi
        else
            echo "오류: gh 로그인이 필요합니다." >&2
            echo "실행 명령어: gh auth login --hostname github.com" >&2
            exit 1
        fi
    fi
}

ensure_gcloud_ready() {
    if ! activate_gcloud; then
        echo "Google Cloud CLI(gcloud)가 설치되어 있지 않습니다."
        if confirm "Homebrew로 google-cloud-sdk를 설치할까요?"; then
            if ! command -v brew >/dev/null 2>&1; then
                echo "오류: Homebrew가 설치되어 있지 않아 google-cloud-sdk를 자동 설치할 수 없습니다." >&2
                echo "Homebrew 설치: https://brew.sh" >&2
                exit 1
            fi
            brew install --cask google-cloud-sdk
            if ! activate_gcloud; then
                echo "오류: google-cloud-sdk 설치 후에도 gcloud 명령어를 찾을 수 없습니다." >&2
                echo "터미널을 재시작한 뒤 다시 make pull-secrets를 실행해 주세요." >&2
                exit 1
            fi
        else
            echo "오류: gcloud 설치가 필요합니다." >&2
            echo "설치 명령어: brew install --cask google-cloud-sdk" >&2
            exit 1
        fi
    fi

    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        echo "gcloud에 로그인된 계정이 없습니다."
        if confirm "Google 계정으로 로그인할까요?"; then
            gcloud auth login
            if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
                echo "오류: gcloud 로그인 완료 상태를 확인할 수 없습니다." >&2
                echo "실행 명령어: gcloud auth login" >&2
                exit 1
            fi
        else
            echo "오류: gcloud 로그인이 필요합니다." >&2
            echo "실행 명령어: gcloud auth login" >&2
            exit 1
        fi
    fi

}
