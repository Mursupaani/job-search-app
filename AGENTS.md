# Job Search App review guidance

## Communication preferences

- Keep routine steps quiet. Send a progress update when a finding changes the
  approach, you're blocked, or you need a decision from me.
- Lead with what matters most to me. For an app change, say what I'll notice.
  For a review, lead with the most important finding. Aim for a final reply I
  can read in 30 seconds. A trivial edit may need only one sentence.
- When a code detail helps me understand or predict the app's behavior, weave
  it into the result in plain language. For a bug, connect one concrete action
  to its cause and fix. Link to the relevant code when useful. Skip concepts
  you've already explained in this conversation unless the change adds
  something new.
- Use one line to say what you checked and whether it passed. Flag anything
  important that's still unverified or needs my decision.
- Give a deeper walkthrough when I ask. Skip recaps, file-by-file summaries,
  and closing offers to explain more.

## Tool use

Use command-line tools first for all project work, including `git` and `gh`
for Git and GitHub. If a command-line tool is unavailable or cannot complete
the task, explain to the user what the CLI could not do and why you need the
alternative before attempting to use it. This includes opening a browser or
triggering a browser access prompt.

## Before starting work or making recommendations

Before starting work on any issue or recommending a workflow or dependency,
check applicable industry standards and current best practices. Use primary
sources such as standards bodies, official documentation, and security
guidance. Explain what applies to this project and cite the sources that
inform the proposed approach.

## Before publishing changes to GitHub

Before starting issue work or opening a pull request, follow the
[GitHub delivery rules](HARNESS.md#github-issues-review-and-delivery).
Find or create the issue the change addresses, then include its link in the
description passed to the project's PR-opening workflow. Use `Closes #123`
when merging the PR should close issue 123. Before reporting the PR ready,
check its published description for the intended issue link.

Before publishing each revision, inspect the exact files and filenames being
published for the personal information and secrets described below. Open
screenshots and other visual files when they are included. Remove sensitive
details or replace them with fictional values before pushing a branch or
creating a commit directly on GitHub.

## After opening or updating a pull request

A request to open or update a PR includes following it through to human review.
Follow the [delivery rules](HARNESS.md#github-issues-review-and-delivery)
without waiting for another prompt. Watch CI on the latest commit. Once CI
passes, post `@codex review` unless a review has already been requested or
completed for that commit. Wait for the published Codex verdict. Address
in-scope failures or findings and repeat the checks for each new commit.
Ask for human approval when both CI and the verdict pass on the latest commit.
If progress requires the user's help, report the specific blocker.

## Code Review Rules

### Check every change for personal information and secrets

- On every review, check the changed files and filenames for sensitive data.
  Include documentation, configuration, tests and fixtures, screenshots,
  sample CVs and cover letters, logs, and other generated or exported files.
  Read the surrounding content when it helps identify what a value represents.
- Flag real or plausibly real personal details, including names, personal
  usernames, email addresses, phone numbers, street addresses, local home
  directory paths, and identifying information in CVs or application records.
  Consider capitalization, accents, and alternate spellings.
- Flag embedded credentials and secret material, including API keys, access
  tokens, passwords, private keys, session cookies, and connection strings
  that contain credentials. Check for values spread across multiple lines or
  embedded in examples and logs.
- Treat an unauthorized exposure of personal information or a credible secret
  as a blocking finding. Report the file and location, the type of information
  exposed, and a safe replacement. Redact sensitive values in all review
  comments and summaries. Use fictional data in examples and fixtures.
- Public platform identifiers and references to credentials injected at runtime
  are allowed when they serve a documented purpose. Verify what a value
  represents before classifying it as sensitive.
