#!/usr/bin/env python3
"""
코드 리뷰 결과를 GitHub API를 통해 PR 코멘트로 전송합니다.

사용법:
    python start-code-review.py --owner OWNER --repo REPO --pr PR_NUMBER --token TOKEN
"""

import argparse
import json
import subprocess
import sys

import requests

GITHUB_HEADERS = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2026-03-10",
}


def _headers(token: str) -> dict:
    return {**GITHUB_HEADERS, "Authorization": f"Bearer {token}"}


def send_review(owner: str, repo: str, pr_number: int, token: str, review_data: dict) -> dict:
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/reviews"
    response = requests.post(url, headers=_headers(token), json=review_data)
    response.raise_for_status()
    return response.json()


def get_existing_comments(owner: str, repo: str, pr_number: int, token: str) -> list[dict]:
    """PR의 모든 리뷰 코멘트를 조회합니다."""
    comments = []
    page = 1

    while True:
        url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/comments"
        response = requests.get(url, headers=_headers(token), params={"page": page, "per_page": 100})
        response.raise_for_status()
        page_comments = response.json()

        if not page_comments:
            break

        comments.extend(page_comments)
        page += 1

    return comments


def _comment_key(comment: dict) -> tuple:
    """중복 판별을 위한 코멘트 키를 생성합니다."""
    return (
        comment.get("path"),
        comment.get("body"),
        comment.get("line"),
        comment.get("side"),
        comment.get("start_line"),
        comment.get("start_side"),
    )


def filter_duplicate_comments(review_data: dict, existing_comments: list[dict]) -> dict:
    """기존 코멘트와 중복되는 새 코멘트를 제외합니다."""
    existing_keys = {_comment_key(c) for c in existing_comments}
    new_comments = [
        c for c in review_data.get("comments", [])
        if _comment_key(c) not in existing_keys
    ]

    return {**review_data, "comments": new_comments}


def get_review_data(owner: str, repo: str, pr_number: int, token: str) -> dict:
    result = subprocess.run(
        [
            sys.executable,
            "Tools/code-review/create-review-result.py",
            "--owner", owner,
            "--repo", repo,
            "--pr", str(pr_number),
            "--token", token
        ],
        capture_output=True,
        text=True,
        check=True
    )

    return json.loads(result.stdout)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="코드 리뷰 결과를 GitHub API를 통해 PR 코멘트로 전송"
    )
    parser.add_argument("--owner", required=True, help="리포지토리 소유자명")
    parser.add_argument("--repo", required=True, help="리포지토리 이름")
    parser.add_argument("--pr", required=True, type=int, help="PR 번호")
    parser.add_argument("--token", required=True, help="GitHub API 토큰")

    args = parser.parse_args()

    try:
        print("코드 리뷰 생성 중...")
        review_data = get_review_data(args.owner, args.repo, args.pr, args.token)

        print("기존 코멘트 조회 및 중복 필터링 중...")
        existing = get_existing_comments(args.owner, args.repo, args.pr, args.token)
        review_data = filter_duplicate_comments(review_data, existing)

        if not review_data.get("comments"):
            print("전송할 새로운 코멘트가 없습니다.")
            return

        print(f"PR #{args.pr}에 리뷰 전송 중... ({len(review_data['comments'])}개 코멘트)")
        result = send_review(args.owner, args.repo, args.pr, args.token, review_data)

        print("리뷰가 성공적으로 전송되었습니다!")
        print(f"리뷰 ID: {result.get('id', 'N/A')}")
        print(f"HTML URL: {result.get('html_url', 'N/A')}")

    except subprocess.CalledProcessError as e:
        print(f"리뷰 생성 실패: {e}", file=sys.stderr)
        if e.stderr:
            print(f"stderr: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        print(f"GitHub API 요청 실패: {e}", file=sys.stderr)
        try:
            print(f"상세 정보: {json.dumps(e.response.json(), indent=2)}", file=sys.stderr)
        except Exception:
            pass
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"JSON 파싱 실패: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"오류 발생: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
