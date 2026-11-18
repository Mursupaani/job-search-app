"""Publish the Codex verdict for the current head of a pull request."""

import json
import os
import re
import subprocess


CODEX_APP_ID = 1144995
CODEX_BOT_ID = 199175422
CHECK_NAME = "Codex review verdict"
CHECK_DETAILS = "https://github.com/{repo}/pull/{number}#issuecomment-{comment_id}"
SUMMARY_MARKER = "<!-- codex-pull-request-review-summary -->"
REVIEW_MARKER = re.compile(r"^<!-- codex-review-state:v1 (.+) -->$", re.MULTILINE)


def is_codex_comment(comment):
    return (
        (comment.get("user") or {}).get("id") == CODEX_BOT_ID
        and (comment.get("performed_via_github_app") or {}).get("id") == CODEX_APP_ID
    )


def review_verdict(comments, head_sha):
    summaries = [
        comment for comment in comments
        if is_codex_comment(comment) and SUMMARY_MARKER in (comment.get("body") or "")
    ]
    if len(summaries) != 1:
        return None, "Waiting for a unique review summary from Codex", None

    summary = summaries[0]
    markers = REVIEW_MARKER.findall(summary["body"])
    if len(markers) != 1:
        return None, "Codex review result is missing or unreadable", summary
    try:
        state = json.loads(markers[0])
    except json.JSONDecodeError:
        return None, "Codex review result is unreadable", summary

    review = state.get("code_review") if isinstance(state, dict) else None
    if not isinstance(review, dict) or review.get("commit_sha") != head_sha:
        return None, "Waiting for Codex to review the latest commit", summary
    if review.get("status") != "completed":
        return None, "Waiting for a completed Codex review", summary
    if review.get("has_unresolved_findings") is True:
        return "failure", "Codex found unresolved issues", summary
    if review.get("has_unresolved_findings") is False:
        return "success", "Codex reviewed the latest commit with no unresolved findings", summary
    return None, "Codex review verdict is missing", summary


def gh_api(path, *args, payload=None):
    command = ["gh", "api", path, *args]
    if payload is not None:
        command.extend(["--input", "-"])
    result = subprocess.run(
        command, input=json.dumps(payload) if payload is not None else None,
        capture_output=True, check=True, text=True,
    )
    return json.loads(result.stdout)


def publish(repo, number, head_sha, conclusion, details, summary):
    # Keep one check per commit and PR, including when Codex edits its comment.
    external_id = f"codex-code-review:{number}:{head_sha}"
    pages = gh_api(
        f"repos/{repo}/commits/{head_sha}/check-runs",
        "--method", "GET", "-f", f"check_name={CHECK_NAME}", "-f", "filter=all",
        "--paginate", "--slurp",
    )
    check = next((
        check for page in pages for check in page["check_runs"]
        if check["app"]["slug"] == "github-actions" and check["external_id"] == external_id
    ), None)
    if check is not None and conclusion is None and check["status"] == "completed":
        # A completed check cannot be reopened. Fail it until a fresh verdict arrives.
        conclusion = "failure"

    payload = {
        "name": CHECK_NAME,
        "external_id": external_id,
        "details_url": details,
        "status": "completed" if conclusion else "in_progress",
        "output": {"title": CHECK_NAME, "summary": summary},
    }
    if conclusion:
        payload["conclusion"] = conclusion
    if check:
        return gh_api(f"repos/{repo}/check-runs/{check['id']}", "--method", "PATCH", payload=payload)
    payload["head_sha"] = head_sha
    return gh_api(f"repos/{repo}/check-runs", "--method", "POST", payload=payload)


def main():
    repo = os.environ["GH_REPO"]
    number = int(os.environ["PR_NUMBER"])
    pr = gh_api(f"repos/{repo}/pulls/{number}")
    if pr["state"] != "open" or pr["base"]["ref"] != "main":
        return
    head_sha = pr["head"]["sha"]
    pages = gh_api(f"repos/{repo}/issues/{number}/comments", "--paginate", "--slurp")
    comments = [comment for page in pages for comment in page]
    conclusion, summary, comment = review_verdict(comments, head_sha)
    details = (
        CHECK_DETAILS.format(repo=repo, number=number, comment_id=int(comment["id"]))
        if comment else f"https://github.com/{repo}/pull/{number}"
    )
    check = publish(repo, number, head_sha, conclusion, details, summary)
    print(f"{head_sha[:7]}: {check['status']} ({check['conclusion']}) — {summary}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        raise SystemExit(error.stderr.strip() or "GitHub API call failed.") from error
