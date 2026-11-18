# Prototype database schema

This is the design to review before writing PostgreSQL migrations. The
[development harness](../HARNESS.md) defines app behavior and the approval
process. [Job matching](matching.md) defines the scoring rules.

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
| `assessment_criteria` | One criterion evaluated in an assessment | Assessment, requirement or preference, essential or bonus classification when applicable, match rating, and evidence used in the assessment. |
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
| `document_versions` | A saved version of a CV or cover letter | Document, saved Typst source, save time, and optional photo reference for a CV. |
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
| `background_jobs` | A queued task | Owner, task type, related posting when applicable, queue time, and status. |
| `ai_requests` | An attempt to call OpenAI | Account, originating job when applicable, model, reservation and reported usage, estimated cost, and the exchange rate used when applicable. A job can make multiple requests. |
| `model_prices` | A supported model's pricing | Input, cached input, and output rates, with the date and time they were last verified. Updates apply to future requests. |
| `exchange_rates` | A published ECB rate | Publication date and US dollars per euro. Save the rate used for a converted estimate so the calculation can be reproduced. |
| `account_ai_settings` | An account's AI settings | Model choices, monthly token limit, and optional monthly spending cap and currency. |
| `app_ai_settings` | Shared AI settings | Optional app-wide monthly spending cap and currency. |

Save a new posting and queue its assessment in one transaction. A worker can
read the queued task from PostgreSQL after a restart. Before making an AI
request, check the active limits and reserve usage in one transaction. When
reported usage arrives, record it and release any unused reservation. Follow
the [AI usage and pricing rules](../HARNESS.md#8-ai-usage-spending-and-data-protection)
for caps, retries, missing prices, and account deletion.

## Walk through a submission

Record an application with CV version 3 and then save another edit as
version 4. Opening the current draft should show version 4. Opening the CV from the
application record should still show version 3. The React page calls the
Node.js API. The server checks the session and posting ownership, then uses a
SQL join to follow the application to the selected document version.
