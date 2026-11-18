"""Verify which Codex responses may satisfy the required check."""

import json
import unittest

from codex_review_status import CODEX_APP_ID, CODEX_BOT_ID, review_verdict


def comment(review, app_id=CODEX_APP_ID, bot_id=CODEX_BOT_ID):
    body = json.dumps({"code_review": review})
    return {
        "id": 1,
        "performed_via_github_app": {"id": app_id},
        "user": {"id": bot_id},
        "body": f"<!-- codex-pull-request-review-summary -->\n<!-- codex-review-state:v1 {body} -->",
    }


class ReviewVerdictTests(unittest.TestCase):
    def test_only_a_genuine_completed_review_of_the_latest_head_can_pass(self):
        clean = {"commit_sha": "current", "status": "completed", "has_unresolved_findings": False}
        cases = [
            ("clean latest review", [comment(clean)], "success"),
            ("unresolved findings", [comment({**clean, "has_unresolved_findings": True})], "failure"),
            ("no review", [], None),
            ("wrong app", [comment(clean, app_id=1)], None),
            ("wrong author", [comment(clean, bot_id=1)], None),
            ("ambiguous summary", [comment(clean), comment(clean)], None),
            ("older commit", [comment({**clean, "commit_sha": "older"})], None),
            ("pending review", [comment({**clean, "status": "running"})], None),
            ("skipped review", [comment({**clean, "status": "skipped"})], None),
            ("malformed verdict", [comment({**clean, "has_unresolved_findings": "false"})], None),
            ("security review only", [comment(None)], None),
            ("malformed JSON", [{**comment(clean), "body": "<!-- codex-pull-request-review-summary -->\n<!-- codex-review-state:v1 {bad} -->"}], None),
        ]
        for name, comments, expected in cases:
            with self.subTest(name=name):
                self.assertEqual(review_verdict(comments, "current")[0], expected)
