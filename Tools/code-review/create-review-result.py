#!/usr/bin/env python3
"""
PR diff를 파싱하여 Claude Code로 코드 리뷰를 생성하고 GitHub API 호환 JSON으로 출력합니다.

사용법:
    python create-review.py --owner OWNER --repo REPO --pr PR_NUMBER --token TOKEN
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

import requests

JSON_SCHEMA = {
    "type": "object",
    "properties": {
        "event": {
            "type": "string",
            "enum": ["COMMENT"],
            "default": "COMMENT",
        },
        "comments": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "저장소내 파일의 상대 경로입니다.",
                    },
                    "body": {
                        "type": "string",
                        "description": "리뷰 코멘트 내용입니다."
                    },
                    "start_line": {
                        "type": "number",
                        "description": "멀티라인 코멘트의 시작 라인 번호입니다."
                    },
                    "start_side": {
                        "type": "string",
                        "enum": ["LEFT", "RIGHT"],
                        "description": "멀티라인 코멘트의 시작 라인이 속한 위치(LEFT/RIGHT)입니다."
                    },
                    "line": {
                        "type": "number",
                        "description": "단일 라인은 해당 라인의 번호이며, 멀티라인은 범위의 마지막 라인 번호입니다."
                    },
                    "side": {
                        "type": "string",
                        "enum": ["LEFT", "RIGHT"],
                        "description": "단일 라인은 해당 라인이 속한 위치(LEFT/RIGHT), 멀티라인은 범위의 마지막 라인이 속한 위치(LEFT/RIGHT)입니다."
                    }
                },
                "required": ["path", "body"]
            }
        }
    },
    "required": ["event", "comments"]
}

REVIEW_COMMENT_GUIDE = """
    # Diff 데이터 구조

    입력으로 전달되는 diff 데이터는 아래 XML 형식입니다:

    ```xml
    <file name="경로" status="modified | added | removed | renamed">
        <deleted line="10" side="LEFT">삭제된 코드</deleted>
        <added line="10" side="RIGHT">추가된 코드</added>
    </file>
    ```
    XML형식내 요소들은 다음을 의미합니다.
    - `<deleted>`: 기존 파일에서 삭제된 라인 (LEFT side)
    - `<added>`: 새 파일에 추가된 라인 (RIGHT side)
    - `line`: 파일 내 절대 라인 번호
    - `side`: LEFT (기존 코드), RIGHT (변경 후 코드)

    # 리뷰할 파일의 라인 지정 규칙

    코멘트를 남길 때 반드시 아래 규칙을 따르세요:

    1. `path`는 `<file>` 태그의 `name` 속성값과 정확히 일치해야 합니다.
    2. `line`, `side`, `start_line`, `start_side`는 반드시 diff에 존재하는 라인의 값이어야 합니다.
        - 단일 라인 코멘트의 경우 `line`, `side`를 사용합니다.
        - 멀티라인 코멘트의 경우:
            - 시작 라인의 정보를 `start_line`, `start_side`에 설정합니다.
            - 마지막 라인의 정보를 `line`, `side`에 설정합니다.
    3. diff에 존재하지 않는 라인 번호나 side 조합은 사용할 수 없습니다. 존재하지 않는 위치를 지정하면 API 에러가 발생합니다.
    4. 작성하려는 리뷰와 관련된 라인만 코멘트에 포함합니다. 불필요한 라인은 포함하지 않습니다.

    # 코드 변경 제안 블록

    필요하다고 판단되는 경우 `body`에는 GitHub의 suggestion 블록을 사용하여 코드 변경 제안을 포함할 수 있습니다.
    
    언어 정보에는 반드시 `suggestion`을 사용해야합니다.
    ````
    ```suggestion
    제안할 코드
    ```
    ````

    - suggestion 블록은 코멘트가 지정된 라인 범위를 대체하는 코드를 나타냅니다.
    - 단일 라인 코멘트의 경우 해당 라인을, 멀티라인 코멘트의 경우 `start_line`부터 `line`까지의 범위를 대체합니다.
    - 리뷰 작성자는 PR 작성자와 동일하므로, suggestion 블록을 통해 구체적인 개선 방법을 제시할 수 있습니다.
"""


def get_script_dir() -> Path:
    return Path(__file__).parent.resolve()


def get_pr_commit_id(owner: str, repo: str, pr_number: int, token: str) -> str:
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2026-03-10",
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json().get("head", {}).get("sha", "")


def get_pr_diff(owner: str, repo: str, pr_number: int, token: str) -> str:
    diff_script = get_script_dir() / "get-pr-diff.py"

    result = subprocess.run(
        [
            sys.executable,
            str(diff_script),
            "--owner", owner,
            "--repo", repo,
            "--pr", str(pr_number),
            "--token", token
        ],
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout


def load_custom_review_prompts() -> str:
    review_file = get_script_dir() / "custom-review-guide.md"

    with open(review_file, "r", encoding="utf-8") as f:
        return f.read()


def prepare_prompt(diff_xml: str, review_prompts: str) -> str:
    return (
        f"{review_prompts}\n\n"
        f"# PR Diff Data\n"
        f"다음은 PR의 diff 데이터입니다:\n\n"
        f"{diff_xml}\n\n"
        f"{REVIEW_COMMENT_GUIDE}"
    )


def call_claude_code(prompt: str, json_schema: dict) -> dict:
    schema_str = json.dumps(json_schema, ensure_ascii=False)

    result = subprocess.run(
        [
            "claude",
            "-p",
            prompt,
            "--model", "opus",
            "--output-format", "json",
            "--json-schema", schema_str,
        ],
        capture_output=True,
        text=True,
        check=True
    )

    output = json.loads(result.stdout)
    if isinstance(output.get("content"), str):
        try:
            return json.loads(output["content"])
        except json.JSONDecodeError:
            pass
    if isinstance(output.get("content"), dict):
        return output["content"]
    return output


def main() -> None:
    parser = argparse.ArgumentParser(
        description="PR diff를 파싱하여 Claude Code로 코드 리뷰를 생성"
    )
    parser.add_argument("--owner", required=True, help="리포지토리 소유자명")
    parser.add_argument("--repo", required=True, help="리포지토리 이름")
    parser.add_argument("--pr", required=True, type=int, help="PR 번호")
    parser.add_argument("--token", required=True, help="GitHub API 토큰")

    args = parser.parse_args()

    try:
        diff_data = get_pr_diff(args.owner, args.repo, args.pr, args.token)
        full_prompt = prepare_prompt(diff_data, load_custom_review_prompts())
        review_result = call_claude_code(full_prompt, JSON_SCHEMA)
        structured_output = review_result["structured_output"]

        structured_output["commit_id"] = get_pr_commit_id(args.owner, args.repo, args.pr, args.token)
        structured_output["body"] = ""

        print(json.dumps(structured_output, indent=2, ensure_ascii=False))

    except subprocess.CalledProcessError as e:
        print(f"Command execution failed: {e}", file=sys.stderr)
        if e.stdout:
            print(f"stdout: {e.stdout}", file=sys.stderr)
        if e.stderr:
            print(f"stderr: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"JSON parsing failed: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
