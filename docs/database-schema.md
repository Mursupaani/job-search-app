# Prototype database schema

This is the design to review before writing PostgreSQL migrations. The
[development harness](../HARNESS.md) defines app behavior and the approval
process. [Job matching](matching.md) defines the scoring rules.

## First migration

The [first application issue](../HARNESS.md#first-development-issues) creates
two tables. The initial `accounts` table has a PostgreSQL-generated integer
primary key, `id`. The database test uses it to create a fictional owner.
The sign-in issue adds the account fields listed below.

| `job_postings` field | What it stores |
| --- | --- |
| `id` | A PostgreSQL-generated integer primary key. |
| `owner_id` | A required foreign key to `accounts.id`. |
| `original_text` | The required posting text as pasted. |
| `source_url` | The source URL as text. Use `NULL` when no URL is supplied. |
| `created_at` | The creation timestamp, set by PostgreSQL when it inserts the row. |

Later posting features add the remaining fields and relationships described
below.

### Run the first migration exercise

The project uses PostgreSQL 19. Local runs and the **Repository smoke check**
both use the official `postgres:19` image so patch updates stay within that
major version.

With Docker running, run this command from the repository root.

```sh
bash db/test-postgresql.sh
```

The command starts an isolated container with a fresh `job_search_test`
database, applies the [two-table migration](../db/migrations/001_accounts_and_job_postings.sql),
runs the [SQL test](../db/tests/save_job_postings.sql), and removes the container
on exit. `psql` is PostgreSQL's command-line client. Its `\gset` command saves
a query's result for reuse, including the IDs returned by `INSERT`.

Expect one foreign-key error for the fictional owner ID `0` followed by three
passing rows. The test checks that the error code is `23503` and exits
unsuccessfully if an assertion fails. In GitHub, open **Repository smoke
check** and expand **Test saving job postings in PostgreSQL** for the same output.

## Ownership of linked records

Relationships between account-owned records must stay within one account. For
example, a posting and its company must share an owner. Use owner-aware
foreign keys in PostgreSQL where practical, alongside the
[server ownership checks](../HARNESS.md#account-isolation).

## Accounts and profiles

| Table | One row represents | Fields and relationships |
| --- | --- | --- |
| `accounts` | An app account | Unique username and sign-in email, password hash, and role. |
| `sessions` | A sign-in session | Account, token hash, expiry, and revocation state. |
| `account_tokens` | A setup, invitation, or password reset link | Purpose, secret hash, expiry, and whether it has been used. A password reset links to an existing account. |
| `profiles` | An account's application profile | One per account. Holds the name and contact details used in applications, optional headline and introduction, and a reference to the current photo. |
| `profile_links` | A user-defined link | Profile, label, URL, and inclusion choices for the CV and cover letter. |
| `career_facts` | A fact about the user's experience | Profile, details such as duration, recency, responsibilities, or outcomes, and confirmation status. Use confirmed facts for assessment and drafting. |
| `skills` | A skill listed on a profile | Profile, skill name, and category of technical or professional. |
| `career_fact_skills` | A link between one fact and one skill | One fact can support several skills, and a skill can draw on several facts. |

When registration succeeds, create the account and consume the setup or
invitation link in one transaction. Signing out revokes the current session.
Resetting a password revokes all sessions for that account.

## Postings and assessments

| Table | One row represents | Fields and relationships |
| --- | --- | --- |
| `companies` | A company saved by one account | Account, name, and optional generated summary, sources, and summary date. Several postings can link to one company. |
| `job_postings` | A posting saved by an account | Owner, original pasted text and optional link, company link if known, posting details, summary, benefits, and relevant dates. |
| `posting_assessments` | A posting's current assessment | Posting, scores, outcome, review explanation, and time assessed. Allow one assessment row per posting. |
| `assessment_criteria` | One criterion evaluated in an assessment | Assessment, requirement or preference, essential or bonus classification when applicable, match rating, supporting evidence, and any extracted numeric value and unit. |
| `preferences` | One of the account's interests or practical preferences | Account, criterion, preference value, multiplier, and any applicable targets or cutoffs. |
| `matching_settings` | An account's general scoring settings | One per account. Holds category minimums, skills weights and credit values, interest dimension weights, and other shared scoring settings. |

A posting can exist while waiting for its first assessment. Re-scoring updates
the current result and its criteria. Preserve the assessment and its evidence
when the posting is marked **Applied**.

## Applications and documents

| Table | One row represents | Fields and relationships |
| --- | --- | --- |
| `applications` | A recorded submission | Posting, submission date and time, and the company name, role, and summary as recorded when applying. Optional links point to the exact CV and cover-letter versions used. |
| `application_replies` | A reply from an employer | Application, date and time received, and message or summary entered by the user. |
| `documents` | A CV or cover letter for a posting | Posting and document type. A document can have several saved versions. |
| `document_versions` | A saved version of a CV or cover letter | Document, editable content and formatting, generated Typst, saved contact details and links, versioned assets, and save time. |
| `document_templates` | An account's default layout for one document type | Account, document type, and reusable Typst layout. Keep one current default per type. |
| `uploaded_files` | A private upload | Owner, file type, and reference to the encrypted file. A photo can be referenced by the profile and several saved CVs. |

Editing a draft saves a new version. The application keeps pointing to the
version selected when the user marked the posting **Applied**. The
[photo replacement rule](../HARNESS.md#profile-page-and-application-details)
allows an explicit change to the photo used by older versions. The
[application record](../HARNESS.md#application-record) displays the update
label in the app.

## Background jobs and AI usage

| Table | One row represents | Fields and relationships |
| --- | --- | --- |
| `background_jobs` | A queued task | Owner, task type, related posting when applicable, input evidence used to check freshness, queue time, and status. |
| `ai_requests` | An attempt to call OpenAI | Random attempt ID, account, originating job when applicable, model, reservation and reported usage, prices and exchange rate at request start when applicable, and estimated cost. A job can make multiple requests. |
| `model_prices` | A supported model's pricing | Input, cached input, and output rates, with the date and time they were last verified. Updates apply to future requests. |
| `exchange_rates` | A published ECB rate | Publication date and US dollars per euro. Save the rate used for a converted estimate so the calculation can be reproduced. |
| `account_ai_settings` | An account's AI settings | Model choices, monthly token limit, and optional monthly spending cap and currency. |
| `app_ai_settings` | Shared AI settings | Optional app-wide monthly spending cap and currency. |
| `deleted_account_spending` | Confirmed spending carried over to the shared cap | Billing month and confirmed spending. |
| `deleted_account_reservations` | An already-sent request awaiting reconciliation after account deletion | Random attempt ID, billing month, reserved amount, prices and exchange rate used when applicable, and reconciliation state. Store only what is needed to settle the reservation. |

Once the application schedules assessments, save a new posting and queue its
assessment in one transaction. A worker can read the queued task from
PostgreSQL after a restart. Before making an AI request, check the active limits
and reserve usage in one transaction. When reported usage arrives, record it
and release any unused reservation. Follow
the [AI usage and pricing rules](../HARNESS.md#8-ai-usage-spending-and-data-protection)
for caps, retries, missing prices, and account deletion.

## Walk through a submission

Record an application with CV version 3 and then save another edit as
version 4. Opening the current draft should show version 4. Opening the CV from the
application record should still show version 3. The React page calls the
Node.js API. The server checks the session and posting ownership, then uses a
SQL join to follow the application to the selected document version.
