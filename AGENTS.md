# Job Search App review guidance

## Tool use

Use command-line tools first for all project work, including `git` and `gh`
for Git and GitHub. If a command-line tool is unavailable or cannot complete
the task, explain to the user what the CLI could not do and why you need the
alternative before attempting to use it. This includes opening a browser or
triggering a browser access prompt.

## Before publishing changes to GitHub

Before publishing each revision, inspect the exact files and filenames being
published for the personal information and secrets described below. Open
screenshots and other visual files when they are included. Remove sensitive
details or replace them with fictional values before pushing a branch or
creating a commit directly on GitHub.

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
