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
pushing to this project's existing private GitHub repository. Do not ask for
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
approved profile, explain the result, and generate a CV and cover letter when
the posting qualifies or the user chooses to proceed after review.

### Initial capabilities

- Compare each posting against the user's skills, interests, and practical
  requirements, showing separate scores and explanations.
- Show **Matches** and **Needs review** on the website as pasted postings
  are processed. Defer email digests beyond the prototype's core workflow.
- Recommend CV changes and draft a cover letter for qualifying positions.
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
- Allow sign-in using either the username or email address with the same password.
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

- Keep one reusable Typst template for CV layout and formatting. When a posting
  qualifies, generate a tailored, standalone `.typ` draft from the current
  template. Draft generation leaves the template intact.
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

- Keep postings with only partial text visible as **Incomplete**.
- Let the user review the available details in the existing record or add the
  full posting to that record. Evaluate the completed description.
- Keep the incomplete status visible until sufficient posting text is available.
  Any assessment based on partial content must be identified as incomplete.

### Data retention

- Retain job descriptions, scores, CV recommendations, and cover-letter drafts
  until the user deletes them.
- Retain technical processing logs for 30 days after each log entry is created,
  then automatically remove expired entries. Logs must not contain email bodies
  or credentials.

## 5. Cover letters

Status: drafting, consistency checks, language rules, editing, and export
approved on 18 November 2026.

### Drafting and review

- Generate the tailored CV and cover letter together when a posting qualifies
  or when the user chooses to proceed with a **Needs review** posting.
- Use only facts supported by the user's approved career profile. The cover
  letter may expand on relevant examples that the tailored CV leaves out.
- Before presenting the drafts for review, check each draft against the
  approved profile and cross-check the two drafts against each other. Check
  claims about dates, titles, qualifications, skills, and responsibilities.
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
- Render a PDF preview automatically for the first draft. After edits, let
  the user refresh the preview on demand. **Download PDF** renders the latest
  version, including edits made since the last preview.
- Provide **Copy letter** for application forms. Copy plain text with readable
  paragraph breaks and list markers.

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

- Automatically save both drafts as standalone `.typ` files with the job
  posting when they are generated. Let the user reopen either document and
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
- Insert the user's selected name, contact details, links, and optional CV
  photo locally when rendering the application documents.

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
- Warn the user when usage reaches 90% of their monthly token limit. Inform
  them again when the limit prevents a request from starting.
- Offer an optional monthly spending cap, off by default. The user chooses
  a cap in USD or EUR. When enabled, enforce it against estimated API charges
  from this app.
- Let the administrator set an optional monthly spending cap for the whole
  app in USD or EUR. Apply it across all accounts, alongside each account's
  own limits. When an account is deleted, keep its spending in the app-wide
  total for the current month without retaining its per-account usage history.
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

### AI request retries

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
  requests and preserve the estimates already recorded.
- Show the date and time each selected model's prices were last updated in
  **AI settings**. If pricing is missing for any selected model, disable
  enabling the spending cap and identify the model that is missing prices.
- If pricing is unavailable for a request subject to an enabled spending
  cap, keep the cap active and pause the request. Let the user choose a
  model with known prices. Each cap can be turned off only by the user or
  administrator who controls it. Token limits still apply.
- Check the [ECB Data API](https://data.ecb.europa.eu/help/api/data-examples)
  once per day for the latest USD/EUR reference rate. Use the latest
  published rate on weekends and holidays. Convert estimated USD charges
  with that rate when enforcing a euro spending cap.

### Data encryption

- Encrypt all user data at rest and in transit, including career profiles,
  saved postings, CVs, cover letters, application records, replies, and backups.
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
  scheduled backups. A manual encrypted backup is the first backup option to
  add when real CVs or application history need protection.

The later [Google Drive backup and restore procedure](docs/deferred-integrations.md#google-drive-backups-and-restore) covers scheduled backups, retention, and recovery on a fresh server.

## 10. Build and rollout

### Technology stack

- Build the browser interface in React and TypeScript. Use a Node.js HTTP API
  written in TypeScript and PostgreSQL for persistence.
- Review the [database schema](docs/database-schema.md) together before writing
  migrations. Use the job-posting workflow to trace the path from a browser
  request through API validation and ownership checks to a database write.

### GitHub issues, review, and delivery

- Work on one active GitHub issue at a time. Codex creates the issues and pull
  requests. Each issue describes the expected behavior, how to verify it, and
  what the user will learn about the stack.
- Require two sign-offs on the latest revision before merging. An independent
  agent reviews the PR automatically, and the user approves it on GitHub.
  Open development PRs under an identity distinct from the user's. Use a
  required status check for the agent's verdict if its review cannot count as
  a required GitHub approval. Verify both merge requirements in the private
  repository when setting up the workflow.
- Set up CI/CD. Run tests and build checks on PR revisions. Prepare a verified
  build for deployment and connect deployment when the hosting target is ready.
  Explain CI and CD during implementation by walking through the first pipeline
  run and how to verify the deployed version.
- Make learning full-stack development a project goal. Walk through the code
  and show how to exercise each change locally when presenting its PR for review.

The first build milestone and its acceptance criteria are pending approval.
