# Job Search App — Development Harness

Build this harness one section at a time. Discuss and refine each section with the
user before writing it. Write or revise a section only when the user explicitly
instructs you to do so. Unresolved decisions must remain explicit rather than
being filled in as approved requirements.

Apply these planning rules to this harness and its linked requirements.
During development, if a proposed implementation would change an approved
requirement, explain the change, the reason for it, and its effect. Obtain the
user's explicit approval before implementing it. Update the file that owns the
requirement in the same change as the implementation. Routine implementation
choices that satisfy the requirement can proceed under the existing approval.

If the app already diverges from an approved requirement, treat the difference
as a bug and restore the documented behavior. To keep the different behavior,
follow the same approval and documentation process.

The user's approval of project changes also authorizes routine Git operations
needed to record and sync those changes, including staging, committing, and
pushing to this project's public GitHub repository. Do not ask for
separate conversational permission for these operations. This does not override
tool-enforced sandbox restrictions or authorize unrelated changes, destructive
history rewrites, or changing repository visibility.

## How to use this harness

The prototype workflow runs from an approved career profile and a pasted
posting through assessment, review of the CV and cover letter, and manually
marking the application **Applied** after submission.

- [Matching](docs/matching.md) covers the interview, scoring settings, and qualification rules.
- [Database schema](docs/database-schema.md) describes the prototype's tables and their relationships.
- [Deferred integrations](docs/deferred-integrations.md) covers Gmail intake, posting retrieval, email digests, and scheduled Google Drive backups.
- Open planning items include [hosting](#deployment-and-background-operation), [email source validation](docs/deferred-integrations.md#open-decisions-for-this-section), and [build and rollout](#10-build-and-rollout).

## 1. Scope and operating environment

Status: approved for writing on 17 November 2026.

### Purpose and users

Build a personal job-search web app that helps the user identify suitable
positions and prepare applications. The initial user is the project owner.
Keep a path to adding users later, with records associated with their owning
account from the beginning. Public registration is disabled initially.

### Supported inputs

For the prototype, accept only job postings pasted into the app as text. Let
the user save the original link if available. Assess the posting against the
approved profile and explain the result. Let the user choose which drafts to
generate as described in section 5.

### Initial capabilities

- Compare each posting against the user's skills, interests, and practical
  requirements, showing separate scores and explanations.
- Show **Matches** and **Needs review** on the website as pasted postings
  are processed. Defer email digests beyond the prototype's core workflow.
- Offer CV and cover-letter drafting on the user's request.
- Draft cover letters in Finnish or English according to the posting's language.
- Present CV recommendations and cover letters for the user's review.

Do not invent personal qualifications or preferences to fill gaps.

### User control

The app does not submit applications. The user always controls submission.
CV changes are recommendations and cover letters are drafts; generating them
does not authorize sending them to an employer.

### Authentication and access

- Include username and password protection from the first version.
- Each account has a unique username and a unique email address.
- Allow sign-in using either the username or email address with the same
  password. Reserve `@` for email sign-in and reject it in usernames.
- Start with one administrator account for the project owner.
- Protect private app pages, stored data, and API endpoints with authentication.
- Store passwords using secure password hashing, never as plaintext.
- Keep public registration disabled. Create accounts through the setup and
  invitation flow in section 7.

Section 7 covers account provisioning, password recovery, and session handling.

### Deployment and background operation

- Build a portable web app; the hosting provider is not selected yet.
- Support development on the user's Mac and deployment to a standard Linux server.
- Plan for Docker Compose packaging to make the deployment portable.
- Configure credentials, API keys, and environment-specific settings outside
  application source code.
- Avoid required dependencies on proprietary services of a particular host.
- Preserve prototype data across app restarts. Defer backup automation as
  described in section 9.

Low cost and control over stored data are priorities; minimal maintenance is
desirable. The prospective server may also host the user's website and other
projects. The server provider, plan, location, and spending limits remain open.

### AI processing

External AI processing, such as through the OpenAI API, is permitted for relevant
career-profile information and job-posting text. Keep stored application records
under the user's hosting control. Model selection and spending limits are
defined in [section 8](#8-ai-usage-spending-and-data-protection).

### Current work boundary

The current work is preparation of the harness. This section does not authorize
starting application implementation, purchasing hosting, connecting to live
email, or publishing the project.

## 2. Email access and privacy

Gmail intake and automatic full-text retrieval are deferred. The approved access,
privacy, and retrieval rules are in [Deferred integrations](docs/deferred-integrations.md#2-email-access-and-privacy).

## 3. Career profile and preferences

Status: initial workflow approved on 17 November 2026. CV generation, source
retention, and profile page approved on 18 November 2026.

### CV import and verified profile

- Allow the user to upload a CV in PDF or `.docx` format, or paste its text.
- Extract work experience, skills, education, and languages into an editable
  career profile.
- Let the career profile hold more detail than any individual CV. Record how
  the user applied a skill, how long and how recently they used it, their
  responsibilities, and concrete examples or outcomes when available. Capture
  relevant context, such as the industry or scale of the work.
- Collect this detail from the original CV, profile edits, and short follow-up
  interviews. Save confirmed facts in the profile so they can be reused across
  postings without asking the user to confirm them again.
- Let the user review and correct the extracted facts before approving them.
- Use only user-approved profile facts for job matching, CV recommendations, and
  cover-letter drafting. Extraction alone does not establish a verified fact.
- Do not invent qualifications or experience to fill gaps in the CV.
- Flag unclear extracted CV details for the user to correct, confirm, or skip.
- Retain the original uploaded CV until the user manually deletes it.

### Profile page and application details

- Provide an editable profile page for the user's name as it should appear on
  applications, an optional professional headline and short introduction,
  and their country, city, and street address.
- Let the user set the contact email and phone number for CVs and cover letters.
  Keep the application contact email separate from the account's sign-in email.
- Provide **Add link** on the profile page. Save each custom label and URL to
  the user's profile and let the user edit or remove it later. Examples include
  GitHub, LinkedIn, a portfolio or homepage, a live project demo, an app store
  listing, a technical blog, an open source contribution, or a certificate
  verification page.
- Let the user choose which contact details and links to include separately
  on the CV and cover letter. Default to city and country for location.
  Include the street address only if selected.
- Let the user upload a profile photo and choose whether to include it when
  reviewing a CV draft. Leave the photo off by default. Omit the photo from
  cover letters.
- If saved CVs use the previous photo when the user replaces it, ask whether
  to keep that photo in those CVs or replace it with the new one. Apply the
  choice only to CVs that use the previous photo.
- Store each photo once per account even if several CVs use it. Remove a
  previous photo when the profile and saved CVs no longer reference it.

The [matching interview](docs/matching.md#guided-preferences) collects the user's preferences.
[Matching settings](docs/matching.md#matching-settings) govern re-scoring after profile or settings changes.

### Application CVs

- Keep one reusable Typst template for CV layout and formatting. When the user
  chooses to generate a CV, create a tailored, standalone `.typ` draft from
  the current template. Draft generation leaves the template intact.
- Follow the template's layout. Make only small layout adjustments when the
  content needs more room or the change improves readability.
- Select and condense approved career-profile facts that are most relevant to
  the posting and fit the CV layout. Tailor the wording and emphasis to each
  posting without changing the underlying facts. Describe skills in the
  application language selected under section 5. Use the posting's terminology
  where it accurately reflects the user's skills and experience.
- Let the user edit the CV draft in the app.
- Compare the first tailored draft with the saved CV version used to start it.
  If the user selects **Use as starting point**, compare with that selected
  CV version. If no starting CV exists, save a base version from the approved
  profile before tailoring it.
- Show a readable diff and briefly explain the proposed changes. Let the user
  approve the draft or request changes. For revisions, compare the new draft
  with the version the user last reviewed.
- During review, ask separately whether to use the draft as the template for
  future CVs. If the user confirms, replace the current template with the draft's
  layout and formatting. Keep job-specific wording with the application.
- Save the editable `.typ` draft with its posting as described in section 6.
  Render CV PDFs on demand without retaining them.
- Provide a Delete button for the saved CV and require confirmation before
  removing it. Retain saved CVs until the user confirms deletion.

## 4. Job matching and notifications

Status: approved for writing on 18 November 2026.

See [Job matching](docs/matching.md) for the interview, scoring formulas, and rules for assigning a posting's outcome.

### Saved postings

- For every assessed posting, save a short summary, the company name, the
  position title, and the original link if provided. Apply this to **Match**,
  **Needs review**, and **Below minimums**. Show unknown values when the
  company name or position title is missing.
- Keep the original pasted text, the date and time the posting was added,
  and the date and time it was last assessed. Record the employer's
  publication date and application deadline separately when provided.
  Preserve date-only deadlines as dates.
- Save location, work arrangement, salary range, and contract type when
  stated. Keep the assessment outcome, scores, and a short explanation.
- List any benefits stated in the posting, including any stated conditions,
  regardless of the assessment outcome or whether the benefits affect scoring.

### In-app results

Show **Matches** and **Needs review** separately in the app as postings are
processed. Later email delivery is covered in [Email digests](docs/deferred-integrations.md#email-digests).

### Incomplete postings

- Keep postings that appear cut off or refer to missing parts of the
  description visible as **Incomplete**. Identify any assessment of partial
  content as incomplete.
- Let the user review the available details, add the missing text to the
  existing record, or select **This is the full posting**. Apply the
  [normal matching rules](docs/matching.md#qualification-and-review) when
  sufficient text is available or the user confirms the posting is complete.

### Data retention

- Retain job descriptions, scores, CV recommendations, and cover-letter drafts
  until the user deletes them.
- Retain technical processing logs for 30 days after each log entry is created,
  then automatically remove expired entries. Log operational metadata such as task type, outcome, and token count.
  Keep raw prompts, replies, documents, email bodies, and credentials out
  of logs, including when requests fail.

## 5. Cover letters

Status: drafting, consistency checks, language rules, editing, and export
approved on 18 November 2026.

### Drafting and review

- For a **Match**, offer **Generate CV**, **Generate cover letter**, and
  **Generate both**. Start drafting only after the user explicitly chooses
  an action, and generate the selected documents.
- For a **Needs review** posting, show the review summary first. Let the user
  address the reason for review or choose to proceed with the uncertainty
  visible. If the user confirms new facts, re-score before they decide. Offer
  the same three drafting actions after the user chooses to proceed.
- Use only facts supported by the user's approved career profile. The cover
  letter may expand on relevant examples that the tailored CV leaves out.
- Before presenting a new draft for review, check it against the approved
  profile. When both types of draft exist for the posting, cross-check them,
  including when one was generated separately. Check claims about dates,
  titles, qualifications, skills, and responsibilities.
- Show the relevant passages together when the drafts conflict and ask the
  user to resolve the discrepancy.
- After the user saves a wording change in either draft, run the consistency
  check again and flag any new conflicts. Formatting, layout, and photo
  changes do not trigger an AI check.

### Application language

- Use the same language, Finnish or English, for the tailored CV and cover
  letter. Follow any explicit application language specified in the posting.
- If the posting gives no language instruction, use the language of the main
  job description. If it is evenly split between Finnish and English, ask the
  user to choose before drafting.
- Let the user change the language for both drafts during review.
- Keep the official names, spelling, and capitalization of tools, frameworks,
  libraries, and products in both drafts. Translate the surrounding text.

### Editing, preview, and export

- Save the editable cover letter with its application and let the user edit it
  in a rich text editor. Include font family, size, and color, bold, italics,
  indentation, paragraph alignment and spacing, bulleted and numbered lists,
  links, undo and redo, and clear formatting.
- Use a reusable Typst cover letter template to handle margins and page layout.
  Use the editable content and formatting to generate a standalone `.typ`
  draft. Update that draft when the user saves edits. The first version omits
  tables, images, and custom page layouts.
- For both documents, store the wording as text and keep supported formatting
  as structured data. Generate Typst with app-controlled formatting and
  pass the wording as literal text. Validate link destinations against the
  supported URL schemes before making links clickable.
- Render a PDF preview automatically for the first draft. After edits, let
  the user refresh the preview on demand. **Download PDF** renders the latest
  version, including edits made since the last preview.
- Provide **Copy letter** for application forms. Copy plain text with readable
  paragraph breaks and list markers.
- Test a fictional cover letter with literal characters such as `#` and `$`,
  a list, and a link. Verify the wording and expected formatting in the
  editor, copied letter, and PDF.

**Open for drafting.** Clarify that drafts belong to postings and that a
recorded application can reference the exact versions submitted. Align this
section with the [document relationships](docs/database-schema.md#applications-and-documents).

**Open for Typst export.** Choose how to pin the compiler and fonts. Check
that a saved document keeps its page breaks when rendered on a fresh
installation.

## 6. Application tracking

Status: application records, company pages, document storage and reuse,
template import, writing styles, and manual reply logging approved on
18 November 2026.

### Application record

- When the user selects **Mark as applied** after submitting an application,
  record the submission date and time, the company name, the position title,
  and a short summary of the posting. Keep the summary with the application
  so it remains available if the original link stops working.
- Let the user link the exact versions of the CV and cover letter they used.
  Preserve those versions if the user edits a draft later. The user can mark
  a role **Applied** without linking either document.
- Save editable content and formatting, generated Typst, and the version's
  contact details, links, and assets. Reopen the saved editor content. Render
  submitted versions with their saved contact details and layout, subject to
  the explicit photo replacement rule below.
- Preserve submitted versions when deleting a working draft. For explicit
  deletion of a submitted version, show which application uses it and ask
  for confirmation. Keep the application record and show that its document
  was deleted.
- If the user explicitly replaces the photo in a submitted CV under section 3,
  keep its wording and layout. Show **Photo updated after submission** only in
  the app alongside the CV in the application record.

### Companies

- Provide a **Companies** section for each user. On a company page, show all
  their saved postings for that company and the applications they marked
  **Applied**, including submission dates and reply history.
- Suggest a company when the user adds a posting. Let the user correct a
  posting's company link and merge duplicate company entries.
- Provide **Generate company summary**. Generate and save a short description
  of what the company does only when the user requests it. Record the sources
  used and the date the summary was generated.
- In the prototype, use company details from pasted postings and extra text
  the user provides. If those sources do not support a summary, ask the user
  for more information.

### Saved documents and templates

- Automatically save each generated draft as a standalone `.typ` file with
  the job posting. Let the user reopen either document and
  render a PDF preview on demand. Saved files render independently of later
  changes to the default templates.
- Provide **Use as starting point** to copy a saved CV or cover letter into
  a draft of the same type for another posting.
- Provide **Set as default template** to reuse a saved document's layout and
  formatting as the default template for future drafts of that type. Ask the
  user to confirm which default will be replaced. Change it only after the
  user selects **Replace default**.
- In both reuse workflows, tailor the content to the new posting and check
  it against the approved career profile. Replace wording specific to the
  old application, such as the previous recipient's name in the salutation.

### Template import and writing style

- Offer optional CV and cover letter uploads during onboarding and later in
  **Template settings**. Allow the user to upload either document or both.
  In the prototype, offer a best-effort Typst recreation for `.docx` files
  and PDFs with selectable text. Let the user choose a built-in layout
  instead and preview the result before approval.
- Use a built-in layout when no sample is supplied or the PDF is scanned.
  If the uploaded layout cannot be recreated, offer a built-in layout and
  let the user use any readable text as a writing sample. Defer optical
  character recognition (OCR) for scans.
- An uploaded CV can also supply career facts for review under section 3.
  Approve those facts separately from the template. Use a cover letter upload
  as a reference for layout and structure.
- Offer six writing styles: **Formal**, **Relaxed**, **Playful**,
  **Direct and concise**, **Warm and personable**, and
  **Confident and results-focused**. Let the user choose a default separately
  for each document and change it during draft review.
- Offer **Match my style** alongside the presets. Let the user reuse an
  uploaded CV or cover letter as a writing sample, upload a separate sample,
  or paste sample text. Allow different samples for the two document types
  and let the user replace them in settings.
- Let the user choose the layout and writing style independently. A writing
  sample guides tone, vocabulary, and phrasing. Tailor the draft to the new
  posting and use the approved profile for factual claims.
- Show a rendered sample so the user can review the layout and how the
  writing reads. Use the same facts when previewing different styles.
  Ask for confirmation before replacing a default.

**Open for uploads.** Link this section and [CV import](#cv-import-and-verified-profile)
to the upload timing in [section 10](#after-the-first-milestone).

### Upload and preview safety

- Accept PDF and `.docx` documents and JPEG or PNG profile photos. Verify
  the file's contents and structure on the server against the allowed type.
  Treat file extensions and browser-provided MIME types as hints.
- Set prototype upload limits of 10 MB per document and 5 MB per photo.
  Limit decompressed document size and decoded image dimensions, and enforce
  time and memory limits during processing.
- Store uploads privately and check ownership as described in section 7.
  Process uploads and render previews in isolated jobs without network
  access. Build previews from app-controlled Typst templates.
  Give each render its own Typst project root with only that version's inputs.
- Explain when a file is rejected or cannot be processed. Offer pasted
  text and a built-in layout as a fallback for documents.

### Replies

- Provide a **Log reply** action. Let the user record when the reply arrived
  and paste the message or summarize it in their own words.
- Show logged replies in a timeline so the user can keep a record of multiple
  updates, such as an interview invitation followed by a hiring decision.

## 7. Account access and recovery

Status: invitation-only registration, email onboarding, password recovery,
session handling, account isolation, and administrator-assisted deletion
approved on 18 November 2026.

### Registration and invitations

- Provide a browser registration page. During deployment, create a one-time
  setup link for the project owner to register the first administrator account.
- After the first administrator account is created, require an invitation
  from an administrator to register another account. Keep public sign-ups
  disabled. In the prototype, let the administrator generate a one-time
  invitation link and share it directly with the intended user.
- During registration, collect the user's sign-in email as part of creating
  the app account.

### Account isolation

- Scope profiles, saved postings, companies, documents, and applications to
  the account that owns them. Two accounts that paste the same posting keep
  separate records, scores, drafts, and application histories.
- Check ownership on the server for every read or change, including direct
  links to previews and downloads. Run background jobs under the account
  that owns the work.
- When linking private records, verify that the current account owns both
  records. Enforce this relationship in PostgreSQL where practical, as
  described in the [database schema](docs/database-schema.md#ownership-of-linked-records).
- Verify that an attached version belongs to the account and posting and
  matches the selected document type. Test that two accounts can each attach,
  download, and render their own CV and that cross-account attempts are denied.
- Let the administrator view per-account AI usage and estimated costs as
  described in section 8. Keep profiles and documents private to their
  owners in the app.
- Before inviting users, test with two accounts that submit the same posting.
  Verify that each account can access only its own records and files.

### Password recovery

- In the prototype, let the administrator generate a short-lived, one-time
  password reset link from the server for an invited user's account. The
  administrator shares the link directly so the user can set a new password.
- Provide a server CLI command for administrator recovery.
  Run it from a terminal on the server, such as over SSH. Prompt for the
  new password without echoing it or passing it as a command-line argument.
  Recovery through this command requires server access and works without
  an app session or email delivery.
- When email-based recovery is added, verify the sign-in email before
  allowing a one-time password reset link to be sent to that address.

**Open for password recovery.** Define how a successful reset, including CLI
recovery, invalidates all outstanding reset links and sessions for the
account. Test with two reset links and an existing session.

### Account deletion

- In the prototype, let the administrator delete an invited account from
  the server at the user's request. Give the user a chance to download
  their CVs and cover letters using the existing document controls.
- Before deletion, let the administrator copy a final AI usage breakdown for
  private settlement. Include the billing month, token count, estimated cost,
  and any unconfirmed usage.
- Revoke the account's sessions and remembered sign-ins, cancel queued work,
  and remove the account's profile, postings, companies, saved documents,
  application history, replies, and per-account AI usage history.
- Defer self-service account deletion and full data export.

### Sessions

- Limit repeated failed sign-in attempts before exposing sign-in beyond the local prototype.
- Offer **Remember me** at sign-in, unchecked by default. If selected, set a
  persistent cookie with a fixed 30-day expiry enforced by the server. Otherwise
  use a non-persistent cookie and a shorter server-enforced session expiry.
  Browser closure alone does not reliably end a session.
- Put only a random sign-in token in an authentication cookie. Store a hash of
  the token on the server. Serve the app over HTTPS and set `Secure`,
  `HttpOnly`, and `SameSite=Lax` on authentication cookies. Allow users to
  follow links from email digests while signed in.
- Protect actions that change data against cross-site request forgery (CSRF).
  Opening a digest link displays the posting without changing its state.
- On sign-out, revoke the current session and remembered sign-in on the server.
  After any password reset, revoke all sessions and remembered sign-ins for
  that account.

## 8. AI usage, spending, and data protection

Status: shared AI connection, per-account usage tracking, encryption,
AI data minimization, model settings, and monthly usage controls approved
on 18 November 2026.

### AI connection

- Let the administrator configure one OpenAI project API key on the server.
  All app accounts use this shared connection. OpenAI bills the project.
- Store the key encrypted on the server. Keep it out of user-facing settings
  and logs. If the administrator has not configured the key, users can still
  add and read postings and track applications.

### Data sent to OpenAI

- Treat pasted postings, CV text, writing samples, and uploads as source
  material. Validate proposed facts, ratings, and evidence before use.
- Send only the information needed for the specific AI task. For assessment
  and drafting, use relevant approved career facts, preferences, and posting
  text. Apply the same restriction to writing samples and consistency checks.
- For scoring, send only the confirmed profile details needed to assess the
  posting. Keep the user's employer and project names on the server. Use
  relevant context such as responsibilities, duration, industry, or scale
  when it helps assess a requirement.
- Extract text from CVs and cover letters on the app server. Keep the
  original files and the user's identifying details on the server. Remove
  names, email addresses, phone numbers, street addresses, personal links,
  and other identifying details from user text before sending it to OpenAI.
  Keep profile photos and account details out of all AI requests.
- If the app cannot prepare an excerpt without identifying details, ask the
  user for a clean excerpt before proceeding with the AI task.
- Offer **Preview AI requests before sending**. When enabled, pause each
  request, including background and follow-up calls. Show the exact content
  after redaction and offer **Send** and **Cancel**. Selecting **Send** opens
  a confirmation step with the preview still visible and changes the button
  to **Confirm**. Only **Confirm** authorizes a single request with that
  exact redacted content. Allow cancellation before sending.
- Recheck ownership and applicable limits before sending. If a request waits
  for budget, carry forward the confirmation for that exact content. If the
  content changes before sending, show the updated preview and require
  **Send** followed by **Confirm** again. Apply redaction even when previews
  are disabled.
- Send Responses API requests with `store: false`. Explain that separate
  abuse-monitoring logs can generally retain content for up to 30 days.
  See [OpenAI data controls](https://developers.openai.com/api/docs/guides/your-data).
- Insert the user's selected name, contact details, links, and optional CV
  photo locally when rendering the application documents.

**Open before the first live AI call.** Define how confirmation remains tied
to the exact redacted request across restarts and how one worker claims it
for dispatch. Test that two workers send one confirmed request once and that
a restart before confirmation makes no provider call.

### Model selection

- Use the shared project key on the server to list available models with
  `GET /v1/models`. Filter the results to models the app supports for each task.
- In **AI settings**, let the user choose models separately for assessment
  and for drafting and cross-checking. Let the user choose the same model
  for both. Use the selected model with `POST /v1/responses`.

### Monthly AI limits

- Attribute each AI request to the account that owns the work, including
  requests started by background jobs. Record input and output tokens
  reported by the Responses API and the estimated cost for that request
  when pricing is available.
- Let each user set a monthly token limit in **AI settings**. Show their own
  tokens used, tokens remaining, estimated spending, and when the limit
  resets. Show the administrator a monthly usage and estimated cost
  breakdown by account so users can settle their share privately.
- Reset personal limits and the shared cap at midnight on the first day of
  each month in `Europe/Helsinki`. Show the reset time in settings and
  attribute each request to its start month, even if usage arrives later.
- Warn the user when usage reaches 90% of their monthly token limit. Inform
  them again when the limit prevents a request from starting.
- Offer an optional monthly spending cap, off by default. The user chooses
  a cap in USD or EUR. When enabled, enforce it against estimated API charges
  from this app.
- Let the administrator set an optional monthly spending cap for the whole
  app in USD or EUR. Apply it across all accounts, alongside each account's
  own limits. When an account is deleted, carry its spending into the shared
  monthly total without its account identifier. Cancel queued requests.
  Keep a reservation for each already-sent request against the shared cap.
  Use a random attempt identifier and retain the billing month, reserved
  amount, and applicable prices and exchange rate. Keep this record free of
  account identifiers and request content. Reconcile each reservation once
  when usage arrives and release unconfirmed reservations at reset.
- Before starting an AI request, estimate usage from its input and maximum
  allowed output. Check the account's remaining token allowance and all
  enabled spending caps, then reserve the estimated tokens and any known
  estimated cost.
  Check and reserve in one operation so concurrent jobs cannot use the same
  allowance. Include outstanding reservations when checking each limit.
- When usage is reported, replace the reservation with the reported token
  counts and the cost estimate based on those counts. Queue a job that
  would exceed any limit and tell the user which limit blocked it.
  Recheck queued jobs when a reservation clears, the relevant limit
  resets, or the user or administrator raises the relevant limit. Let users
  add postings, edit drafts, and track applications while AI jobs are queued.
- Explain API provider rate or spending limits separately from limits set in
  this app.

**Open for monetary caps.** Check that the selected models and settings can
be priced for every billable part of a request, including cache writes where
applicable. Decide when personal and shared caps take effect if spending
earlier in the billing month is unknown.

### AI request retries

- Record the attempt before sending and disable automatic SDK retries.
  Apply the same retry policy to unfinished attempts after restart.
- Before saving a result, check ownership, posting status, and whether its
  evidence is current. Keep settings editable while jobs run. Apply the
  latest weights and minimums to valid evidence and reassess requirements
  when their evidence changes. Preserve scores for **Applied** postings.
- Retry automatically only when the failure is retryable and the app can
  confirm the earlier attempt was never processed. Release the reservation
  for that attempt and check the limits again before retrying.
- If a request may have been processed but no result is confirmed, show
  **Couldn't confirm completion** and let the user choose whether to retry.
  Show that attempt's estimated usage separately from confirmed usage and
  count its reservation against the remaining allowance until the usage is
  confirmed or the relevant monthly limit resets. Apply the normal limits
  to any new attempt.

### Pricing and currency conversion

- Keep an administrator-editable price table in the database for supported
  models. Use [OpenAI's published rates](https://developers.openai.com/api/docs/pricing)
  for input, cached input, and output. The administrator verifies the rates
  weekly and before offering a new model. Apply rate changes to future
  requests and preserve the estimates already recorded. Use the prices and
  exchange rate recorded at the start of each request to estimate its cost
  from the reported usage.
- Show the date and time each selected model's prices were last updated in
  **AI settings**. If pricing is missing for any selected model, disable
  enabling the spending cap and identify the model that is missing prices.
- If pricing is unavailable for a request subject to an enabled spending
  cap, keep the cap active and pause the request. Let the user choose a
  model with known prices. Each cap can be turned off only by the user or
  administrator who controls it. Token limits still apply.
- Check the [ECB Data API](https://data.ecb.europa.eu/help/api/data-examples)
  once per day for the latest USD/EUR reference rate. Use the latest
  published rate on weekends, holidays, and during temporary outages. Convert
  estimated USD charges with that rate and show its publication date in
  settings. Until the first rate is available, pause requests covered by a
  euro cap and show **Waiting for an exchange rate**.

### Data encryption

- Encrypt all user data at rest and in transit, including career profiles,
  saved postings, CVs, cover letters, application records, replies, and backups.
- For the fictional-data milestone, use encrypted storage for PostgreSQL
  and temporary document files. Encrypt backups separately. Encrypt the
  shared OpenAI API key on the server with a key kept separately.
- Before using real CVs or inviting another user, decide whether a copy of
  the database must be unreadable without a separate application key.
- Keep encryption keys separate from the stored data. The server may decrypt
  data as needed for authorized operations such as matching, drafting, and
  rendering previews.
- Store account passwords using secure password hashing as described in
  section 1.

## 9. Backups and restore

Status: prototype storage and later Google Drive backups and server restore
approved on 18 November 2026.

### Prototype

- Keep prototype data across app restarts. Defer Google Drive integration and
  scheduled backups. Add manual encrypted backup and restore before relying
  on real applications. Back up the database and saved files together and
  keep the recovery key separately. Restore into a fresh installation and
  verify that a posting, its application history, and the exact linked CV
  are available and that the CV renders.

### Restore safeguards

- Keep sign-in and background jobs paused during restore. Invalidate restored
  sessions and one-time links before reopening sign-in. Check unfinished AI
  requests against the [retry policy](#ai-request-retries) before resuming
  background jobs.
- Before inviting other users, define how long deleted accounts can remain
  in encrypted backups and how to reapply account deletions made after a
  snapshot before reopening a restored app.

**Open before relying on backups with real data.** Define how to hold
restored paid work for review and reconcile spending since the snapshot.
Test with a backup taken while a job is queued and restored after that job
has run.

The later [Google Drive backup and restore procedure](docs/deferred-integrations.md#google-drive-backups-and-restore) covers scheduled backups, retention, and recovery on a fresh server.

## 10. Build and rollout

### Technology stack

- Build the browser interface in React and TypeScript. Use a Node.js HTTP API
  written in TypeScript and PostgreSQL for persistence.
- Before starting the first issue that needs a new framework, library, or tool,
  compare the practical options together and agree on which to use.
- Review the [database schema](docs/database-schema.md) together before writing
  migrations. Use the job-posting workflow to trace the path from a browser
  request through API validation and ownership checks to a database write.

### GitHub issues, review, and delivery

- Work on one active GitHub issue at a time. Codex creates the issues and uses
  the built-in GitHub Actions bot to open pull requests. The user reviews with
  their existing account. Each issue describes the expected behavior, how to
  verify it, and what the user will learn about the stack.
- Link every PR to the GitHub issue it addresses in the PR description.
- Require two sign-offs on the latest revision before merging. For the prototype,
  Codex waits for CI to pass on the commit it intends to present, then posts
  `@codex review` to request an independent Codex review. GitHub Actions
  automatically publishes the verdict as a required check on the reviewed
  commit.
- When CI and the Codex verdict both pass, Codex asks the user for a formal
  **Approve** review on GitHub. Each new commit requires CI, a fresh Codex
  verdict, and a fresh user approval. Require both sign-offs and passing CI
  before merge.
- During CI setup, use a small PR to verify that the bot can open a PR, the user
  can approve it, and GitHub enforces both sign-offs and the CI checks in the
  public repository. If GitHub asks the user to select **Approve workflows to
  run**, that starts the checks. The user submits their code review separately.
- Use fictional data in public issues, pull requests, screenshots, and CI
  output. During the human review, examine changes to `AGENTS.md` and
  `.github/workflows/` for effects on what gets reviewed and what must pass
  before merging.
- Set up CI/CD. Run tests and build checks on PR revisions. Prepare a verified
  build for deployment and connect deployment when the hosting target is ready.
  Explain CI and CD during implementation by walking through the first pipeline
  run and how to verify the deployed version.
- Make learning full-stack development a project goal. Walk through the code
  and show how to exercise each change locally when presenting its PR for review.

  I’m learning full-stack development. Keep each issue focused on one small
  behavior that I can run, inspect, and explain myself. Before starting, tell me
  what I’ll learn, what we’ll build, and how I’ll see that it works. If
  understanding the change requires several unfamiliar concepts, propose a
  smaller first step.

  During the walkthrough, start with the simplest working example, then show how
  the pieces fit together. Explain new tools and terms when we first use them.
  Give me a small change I can make or a result I can predict to check my
  understanding. Wait for me to say I’m ready before moving to the next issue.

**Open for the next review workflow update.** Document who can authorize a
recovery and how a repair PR can receive independent review and passing CI if
the default branch's parser stops recognizing Codex verdicts. Include
`.github/scripts/` in the human review of changes to the review workflow.

### First build milestone

Run the application workflow locally on the user's Mac, from approving a
career profile through recording a submitted application. Use fictional data
and built-in Typst layouts for the walkthrough.

The milestone is complete when the user can do the following.

1. **Sign in and approve a profile.** Start with an editable sample profile or
   paste CV text. Review, edit, and confirm the career facts the app will use
   for assessment and drafting.
2. **Complete a short setup interview.** Answer questions about skills,
   interests, and practical requirements. Review, adjust, and approve the
   suggested scoring minimums and weights. Verify both
   [recalculation examples](docs/matching.md#recalculation-examples): a weight
   change updates the score, and a minimum change can update the outcome
   with the same score.
3. **Save and assess a pasted posting.** Save the text and an optional source
   link. See evidence for the separate skills, interests, and practical fit
   scores. Verify a **Match** and a **Needs review** result, including the short
   explanation of why the latter needs review.
4. **Choose, review, and export drafts.** Verify that a **Match** waits for a
   drafting choice and a **Needs review** posting shows its review first.
   Try **Generate CV**, **Generate cover letter**, and **Generate both**
   with the built-in layouts. Verify that each action generates its selected
   documents. Review the CV diff and any consistency findings. Edit both
   drafts, render previews, and download PDFs.
5. **Record the submission and verify persistence.** Mark the posting
   **Applied** and link the exact CV and cover-letter versions used. Save a
   later edit and check that the application still opens the selected versions.
   Restart the app, sign back in, and reopen the posting, assessment, drafts,
   and application record.

Use fixed AI responses in CI to verify the match, review, and interview cases
repeatably. Use the real AI connection with fictional data during the local
walkthrough to verify that the app turns a live response into scores and
drafts. Trace **Save posting** from the React form through the Node.js API
to the PostgreSQL row, then follow the worker's result back to the browser.
Walk through the CI checks on the PR that introduces the feature.
Enable AI request preview during the fictional walkthrough to verify
redaction, the **Send** to **Confirm** sequence, cancellation, repeated
confirmation, and a content change before sending. Check that failure logs
omit raw content. Test a restart with an unconfirmed request and marking a
posting **Applied** during assessment.
Verify that a submitted CV renders with its saved email and layout after
changing the profile email and default template.

### First development issues

1. **Verify the PR review workflow.** Use a small test PR to verify that the
   GitHub Actions bot opens it, the user can approve it, and GitHub requires the
   user approval, independent review check, and passing CI on the latest
   revision before merge.
2. **Save one pasted posting in PostgreSQL.** Use the agreed
   [first migration schema](docs/database-schema.md#first-migration).
   Apply the migration to an empty test database and create one fictional
   account. Save one posting with a source URL and one without. Read both
   by ID and verify the owner, exact pasted text, source URL or `NULL`, and
   the creation time set by PostgreSQL. Verify that PostgreSQL rejects a
   posting whose owner does not exist. Run the same database test locally
   and in the existing **Repository smoke check**. Walk through
   `CREATE TABLE`, `INSERT`, and `SELECT`.

Build sign-in, the authenticated posting API, the React form, and assessment
queueing in later issues. Keep each issue small enough to verify and explain
on its own. Saving and reopening a posting in the browser is a checkpoint
spanning the database, sign-in, API, and form issues.

#### PostgreSQL walkthrough

Use one PR with three walkthrough checkpoints.

1. **Create the tables.** Inspect one column that links the tables. *Which
   value tells us who owns a posting?*
2. **Save and retrieve a posting.** Insert it, capture its ID, and use that ID
   in a `SELECT`. *If I leave out the URL, what do I expect to read back?*
3. **Test the ownership rule.** Try saving a posting for an account that
   doesn’t exist. *Which part of the table definition makes PostgreSQL reject it?*

Then open the CI run and find the same test you just ran locally.

### After the first milestone

Add CV and cover-letter uploads in the next milestone. Use the CV to propose
career facts for the user to verify. Let both document types provide a sample
for layout or writing style, with the two choices made independently.
Add targeted re-interviews and follow-up questions for unfamiliar job
requirements after the setup interview works end to end.
