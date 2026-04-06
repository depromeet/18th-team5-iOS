#!/usr/bin/env python3
"""
풀리퀘스트의 변경된 파일들의 diff를 파싱하여 LEFT/RIGHT 라인으로 분리합니다.

사용법:
    python get-pr-diff.py --owner OWNER --repo REPO --pr PR_NUMBER --token TOKEN
"""

import argparse
import re
import sys
from xml.sax.saxutils import escape

import requests

# @@ -{start},{count} +{start},{count} @@
HUNK_PATTERN = re.compile(r"@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")


def get_pr_files(owner: str, repo: str, pr_number: int, token: str) -> list[dict]:
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/files"
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2026-03-10",
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()


def parse_patch(patch_string: str) -> list[dict]:
    """patch 문자열을 파싱하여 추가/삭제 라인 목록을 반환합니다."""
    if not patch_string:
        return []

    changes = []
    left_line = 0
    right_line = 0

    for line in patch_string.split("\n"):
        hunk_match = HUNK_PATTERN.match(line)
        if hunk_match:
            left_line = int(hunk_match.group(1))
            right_line = int(hunk_match.group(3))
            continue

        if not line or line.startswith("\\"):
            continue

        prefix = line[0]
        content = line[1:] if len(line) > 1 else ""

        if prefix == " ":
            left_line += 1
            right_line += 1
        elif prefix == "+":
            changes.append(
                {"type": "added", "line": right_line, "side": "RIGHT", "content": content}
            )
            right_line += 1
        elif prefix == "-":
            changes.append(
                {"type": "deleted", "line": left_line, "side": "LEFT", "content": content}
            )
            left_line += 1

    return changes


def process_pr_diff(owner: str, repo: str, pr_number: int, token: str) -> list[dict]:
    files = get_pr_files(owner, repo, pr_number, token)
    result = []

    for file_info in files:
        patch = file_info.get("patch")
        if not patch:
            continue

        result.append({
            "filename": file_info["filename"],
            "status": file_info["status"],
            "changes": parse_patch(patch),
        })

    return result


def format_diff_xml(result: list[dict]) -> str:
    blocks = []

    for file_diff in result:
        lines = [f'<file name="{escape(file_diff["filename"])}" status="{file_diff["status"]}">']

        for change in file_diff["changes"]:
            tag = "deleted" if change["type"] == "deleted" else "added"
            lines.append(
                f'  <{tag} line="{change["line"]}" side="{change["side"]}">'
                f"{escape(change['content'])}"
                f"</{tag}>"
            )

        lines.append("</file>")
        blocks.append("\n".join(lines))

    return "\n\n".join(blocks)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="PR diff를 파싱하여 LEFT/RIGHT 라인으로 분리"
    )
    parser.add_argument("--owner", required=True, help="리포지토리 소유자명")
    parser.add_argument("--repo", required=True, help="리포지토리 이름")
    parser.add_argument("--pr", required=True, type=int, help="PR 번호")
    parser.add_argument("--token", required=True, help="GitHub API 토큰")

    args = parser.parse_args()

    try:
        result = process_pr_diff(args.owner, args.repo, args.pr, args.token)
        print(format_diff_xml(result))
    except requests.exceptions.HTTPError as e:
        print(f"API 요청 실패: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"오류 발생: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
