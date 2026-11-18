# Job Search App — Development Harness

Build this harness one section at a time. Discuss and refine each section with the
user before writing it. Write or revise a section only when the user explicitly
instructs you to do so. Unresolved decisions must remain explicit rather than
being filled in as approved requirements.

The user's approval of project changes also authorizes routine Git operations
needed to record and sync those changes, including staging, committing, and
pushing to this project's existing private GitHub repository. Do not ask for
separate conversational permission for these operations. This does not override
tool-enforced sandbox restrictions or authorize unrelated changes, destructive
history rewrites, or changing repository visibility.

## 1. Scope and operating environment

Status: approved for writing on 17 November 2026.

### Purpose and users

Build a personal job-search web app that helps the user identify suitable
positions and prepare applications. The initial user is the project owner.
Keep a path to adding users later, with records associated with their owning
account from the beginning. Public registration is disabled initially.

### Supported inputs

- Job-alert emails from LinkedIn, Duunitori, and Jobly, received in the dedicated
  Gmail account described in section 2.
- Job postings pasted directly into the app as text.

Email processing is limited to alerts from these enabled job-search sources.
Unrelated email must not be read into the matching workflow, stored, logged, or
sent to an AI provider.
The dedicated mailbox and access boundaries are described in section 2.
The user's main personal mailbox is not connected to the app.

### Initial capabilities

- Compare each posting against the user's skills, interests, and practical
  requirements, showing separate scores and explanations.
- Notify the user when the configured matching thresholds are met.
- Recommend CV changes and draft a cover letter for qualifying positions.
- Draft cover letters in Finnish or English according to the posting's language.
- Present CV recommendations and cover letters for the user's review.

The user's career profile, interests, practical requirements, scoring rules,
thresholds, notification channel, and handling of mixed-language postings will
be specified in later sections. Section 2 defines retrieval and the fallback for
incomplete postings. No personal qualifications or preferences should be
invented to fill these gaps.

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
- Keep public registration disabled; additional accounts may be introduced later.

Account provisioning, password recovery, session handling, and future user
administration will be defined in a later section.

### Deployment and background operation

- Build a portable web app; the hosting provider is not selected yet.
- Support development on the user's Mac and deployment to a standard Linux server.
- Plan for Docker Compose packaging to make the deployment portable.
- Configure credentials, API keys, and environment-specific settings outside
  application source code.
- Avoid required dependencies on proprietary services of a particular host.
- Provide backup and restore procedures for profiles, postings, scores, and drafts.
- Once deployed to an always-on host, check for supported job alerts daily at
  10:00 Helsinki time, independently of the user's Mac and without an open browser.
  Also provide a user-triggered Check now action.

Low cost and control over stored data are priorities; minimal maintenance is
desirable. The prospective server may also host the user's website and other
projects. The server provider, plan, location, and spending limits remain open.

### AI processing

External AI processing, such as through the OpenAI API, is permitted for relevant
career-profile information and job-posting text. Keep stored application records
under the user's hosting control. Select models and define AI spending limits
in a later section.

### Current work boundary

The current work is preparation of the harness. This section does not authorize
starting application implementation, purchasing hosting, connecting to live
email, or publishing the project.

## 2. Email access and privacy

Status: approved for writing on 17 November 2026. Open decisions are listed below.

### Mailbox and enabled sources

- Use `mursupaani.dev@gmail.com` as the dedicated receiving account.
- Initially support job alerts from LinkedIn, Duunitori, and Jobly.
- The user arranges delivery or forwarding of those alerts to this account.
- The app connects only to this dedicated Gmail account. It does not need
  credentials for or access to the user's main personal mailbox.
- Proton Mail is not part of the selected integration.
- Skip messages from sources that are not explicitly enabled.

### Access boundary

- Use the Gmail API's `gmail.readonly` scope to import alerts and its
  `gmail.send` scope to send notification digests from the same dedicated
  account. Send digests only to the configured recipient. Do not request
  permissions to delete, mark messages as read, or otherwise modify inbox mail.
- Explain during connection that Gmail's read permission applies to the connected
  mailbox; an application filter is not a provider-enforced per-sender permission.
- Apply source and date filters before retrieving message bodies. Use only the
  metadata needed to determine whether a message qualifies.
- Validate that a candidate is a job alert from an enabled source before sending
  its content to AI or saving it as an imported alert. Do not treat every message
  from a job-search site's domain as a job alert.
- Do not retain unrelated message content or expose it through logs or AI calls.
- Keep email credentials and OAuth tokens outside source control and out of logs.
- Treat email content as input data, never as instructions that can expand
  mailbox access or change the app's permissions.

The exact sender rules, forwarding-header handling, and validation logic must
be established from representative alerts. Sender addresses and supported
templates must not be guessed during implementation.

### Initial import and subsequent checks

- Record a fixed import-start timestamp when email setup is completed.
- Import only eligible alerts received after that timestamp, using the mail
  provider's recorded receipt time rather than the sender's Date header.
- Exclude messages already in the mailbox at setup. No historical backfill is
  enabled by default.
- Preserve the original cutoff when reconnecting the same account or restarting
  the app; reconnection must not silently change the import window.
- Run checks daily at 10:00 in the `Europe/Helsinki` timezone on the deployed
  server, independently of the user's Mac and browser. Follow local daylight-saving
  changes automatically rather than scheduling against a fixed UTC offset.
- Provide a user-triggered Check now action in addition to the daily schedule.
- If a scheduled check is missed or fails, automatically catch up when the server
  and email connection are available again. Check all unprocessed eligible alerts
  since the last successful run, or since the original import-start timestamp if
  no run has succeeded. Always preserve the setup cutoff.
- Persist progress so a failed or interrupted run cannot silently skip alerts;
  use the same duplicate prevention for scheduled, manual, and catch-up checks.
- Prevent repeated checks and retries from importing the same email twice.
- Consolidate repeated appearances of the same position, including appearances
  across supported sources, into one job record. Preserve source references.

### Full posting retrieval and incomplete alerts

- When an eligible alert contains only a preview, automatically try to retrieve
  the full job description from its posting link.
- If retrieval fails, requires login, or still yields only partial content,
  clearly mark the posting as incomplete and ask the user to paste the full text.
- Do not request or use the user's job-site login to complete retrieval.
- Allow pasted full text to complete the existing job record rather than create
  a duplicate, then evaluate the completed description.
- Keep the incomplete status visible until sufficient posting text is available.
  Any assessment based on partial content must be identified as incomplete.
- Treat retrieved page content as source data, with the same instruction boundary
  as email content.

### Changed postings and repeat notifications

- When updated content for an existing posting is detected during import or
  retrieval, update the existing job record and automatically re-score it.
- Queue another notification if the posting newly becomes a match or needs
  review, or important details of a previously matched role change, such as
  salary, location, or application deadline. Use the digest timing in section 4.
- Repeated alerts with unchanged posting content must not generate duplicate
  notifications.
- Preserve existing CV recommendations and cover-letter drafts for user review;
  an updated posting must not silently overwrite them or the user's edits.

### Data retention

- Retain imported email content in the app for 30 days after import, then
  automatically remove that stored content.
- Retain job descriptions, scores, CV recommendations, and cover-letter drafts
  until the user deletes them.
- Retain technical processing logs for 30 days after each log entry is created,
  then automatically remove expired entries. Logs must not contain email bodies
  or credentials.
- These rules apply only to the app's stored copies. Do not delete or modify
  messages in Gmail.
- Expiring imported email content must not delete the associated job records or
  cause previously processed alerts to be imported again.

### Open decisions for this section

- Supported message templates, source identification rules, and forwarding format.

Incomplete alerts must not be presented as fully assessed job descriptions.
Writing this section does not connect the Gmail account or authorize reading
live email during harness preparation.

## 3. Career profile and preferences

Status: initial workflow approved on 17 November 2026. CV generation and source
retention approved on 18 November 2026.

### CV import and verified profile

- Allow the user to upload a CV in PDF or Word format, or paste its text.
- Extract work experience, skills, education, and languages into an editable
  career profile.
- Let the user review and correct the extracted facts before approving them.
- Use only user-approved profile facts for job matching, CV recommendations, and
  cover-letter drafting. Extraction alone does not establish a verified fact.
- Do not invent qualifications or experience to fill gaps in the CV.
- Flag unclear extracted CV details for the user to correct, confirm, or skip.
- Retain the original uploaded CV until the user manually deletes it.

### Guided preferences

- Collect interests and practical preferences through guided questions.
- Keep preferences separate from factual career information extracted from the CV.
- Ask about target roles, day-to-day tasks, industries, skills the user enjoys
  using or wants to develop, and work they want to avoid.
- Ask about location and commute, remote or hybrid work, salary, working
  languages, seniority, contract type, and travel.
- Support a thorough exploration for a first software developer role. Use
  plain language and concrete examples of tasks, such as building a page,
  writing request-handling logic, or investigating a bug. Explain where
  these tasks appear across developer roles without assuming industry knowledge.
- Ask about onboarding, mentorship, code reviews, and comfort with being
  the only developer on a team.
- Let the user mark an answer as **must have**, **prefer**, or **no preference**.
  If a posting omits a must-have detail, show it as **unknown** and flag it for review.
- Offer **I’m not sure yet** separately from **no preference**. Provide an
  optional follow-up with examples and leave the preference open if the user
  remains unsure.

### Application status and re-scoring

- In the first version, the user selects **Mark as applied** after submitting an
  application themselves.
- When the user updates their approved career profile or preferences,
  automatically re-score saved postings they have yet to apply to.
- Keep existing scores for postings marked **Applied** and preserve existing
  drafts regardless of application status.

### Application CVs

- Keep one reusable Typst template for CV layout and formatting. When a posting
  qualifies, generate a tailored, standalone `.typ` draft from the current
  template. Draft generation leaves the template intact.
- Follow the template's layout. Make only small layout adjustments when the
  content needs more room or the change improves readability.
- Use only facts from the approved career profile. Describe skills in the
  posting's language and use its terminology where it accurately reflects the
  user's skills and experience.
- Show a readable diff against the starting CV content, with a brief explanation
  for each change. Ask the user to approve the draft or request changes. Show the
  revised draft and diff for review after any requested changes.
- During review, ask separately whether to use the draft as the template for
  future CVs. If the user confirms, replace the current template with the draft's
  layout and formatting. Keep job-specific wording with the application.
- Save the approved, editable `.typ` file with its job posting and cover letter.
  Each file contains the content and layout needed to render it independently of
  later template edits. Render PDFs on demand without retaining them.
- Provide a Delete button for the saved CV and require confirmation before
  removing it. Retain saved CVs until the user confirms deletion.

## 4. Job matching and notifications

Status: initial rules approved. Scoring details remain open.

### Setup interview and scoring settings

- During setup, interview the user about their skills, interests, and practical
  requirements. Use their answers to suggest a starting minimum for each score.
- Show the three suggested minimums and briefly explain each suggestion. Let
  the user adjust any minimum before confirming it.
- Offer a more detailed interview for any category the user is unsure about.
  Use concrete examples and present a revised suggestion for that category for
  the user to review and adjust.
- Use the initial interview to suggest personalized weights and practical
  preference values as well as score minimums. Let the user adjust the
  suggestions before confirming them.

### Skills scoring

- By default, give essential employer requirements a weight of 2.0 and bonus
  skills a weight of 1.0. Multiply each weight by 1.0 for a full match, 0.5 for
  a partial match supported by the approved profile, or 0.0 for a clear gap.
- Count each distinct skill requirement once. Divide the total points earned
  by the total possible points for a skills score from 0.0 to 1.0. If the
  posting lists no assessable skills, show the skills score as **Unknown**.
- If a listed skill has an unknown match, show a score range. Use zero points
  for that skill at the lower end and full points at the upper end. If the
  uncertainty could change whether the posting qualifies, explain what is
  unclear and put the posting in **Needs review**.
- Explain which requirements the user fully meets, partly meets, or has no
  confirmed experience for. Gaps in employer requirements affect the skills
  score and do not independently disqualify a posting. The user's own
  must-haves still apply separately.

### Interests scoring

- During the setup interview, ask how much day-to-day work, role, and industry
  matter to the user. Suggest a decimal weight for each and briefly explain the
  suggestions. Let the user adjust the weights before confirming them.
- Rate day-to-day work, role, and industry from 0.0 to 1.0 and explain each
  rating using details from the posting. Calculate the interests score as the
  sum of the weighted ratings divided by the sum of the included weights.
- Leave dimensions marked **No preference** out of the calculation. If a
  dimension matters to the user but the posting leaves it unclear, show a
  score range and flag it for review if the uncertainty could change whether
  the posting qualifies.

### Practical fit scoring

- Rate practical preferences from 0.0 to 1.0. Use the setup interview to
  identify the factors that matter to the user and suggest adjustable weights.
  Calculate practical fit as the weighted average of those ratings.
- Let the user set both a preferred target and a must-have limit for the same
  numeric criterion. Give 1.0 at the preferred target or better and reduce
  the rating linearly to 0.0 at the limit. The limit itself meets the
  must-have. Values beyond it fail that check.
- For categories such as work arrangement, use editable ratings suggested by
  the interview. For a user who prefers on-site work, a hybrid role with
  confirmed daily office access earns 1.0 for work arrangement.
- If a hybrid posting leaves daily office access unclear and the user prefers
  on-site work, offer two choices in **Matching settings**. **Pass** gives
  work arrangement 1.0 and explains the assumption. **Needs review** flags
  the posting and asks the user to confirm office access. An on-site
  must-have requires confirmation in either mode.
- Show a score range for unresolved practical criteria and ask for review
  when the uncertainty could change whether the posting qualifies.

### Matching settings

- Provide a settings page where the user can adjust all scoring parameters
  without editing code, including the three score minimums, skills weights and
  credit values, and the weights and cutoffs for interests and practical fit.
- Use floating-point values for scoring parameters and display them as decimals.
  Provide a slider for the essential-to-bonus weight ratio, starting at 2.0.
- Let the user retake the full interview or start an interview for skills,
  interests, or practical fit. After either interview, show current and
  suggested values side by side and let the user choose which fields and
  weights to update. Keep current values in effect until the user confirms
  and saves the selected changes.
- When the user saves scoring changes, re-score saved postings they have yet
  to apply to. Preserve scores for postings marked **Applied** and keep existing
  drafts, as in section 3.

### Qualification and review

- Score skills, interests, and practical fit separately. Explain each score.
  A posting qualifies automatically when all three scores meet their minimums
  and all must-haves are confirmed.
- Mark an individual criterion **Unknown** when missing, vague, or conflicting
  information prevents a clear comparison with the approved career profile or
  preferences. Mark a clear mismatch **Doesn't meet**. Keep postings with only
  partial text **Incomplete** as described in section 2.
- Put an otherwise promising posting in **Needs review** if an unknown could
  change whether it qualifies. Show other unknowns in the score explanation.
- Also put a posting in **Needs review** when exactly one score falls below its
  minimum and the other two pass. Apply this rule equally to skills, interests,
  and practical fit.
- Also put a posting in **Needs review** when its interests score meets the
  minimum but its skills score falls short, even if practical fit also falls
  short. Explain what makes the role interesting and where the user's
  experience falls short.
- A confirmed must-have mismatch prevents automatic qualification. If the
  posting otherwise qualifies or meets a review rule, put it in **Needs
  review** and include it in the review digest when eligible for notification.
  Identify the failed must-have in the review summary.
- Give each **Needs review** posting a short summary explaining why review is
  needed. Identify what needs checking or show the score that fell short, its
  minimum, and the reason for the shortfall.
- Let the user add information they learn from the employer to the posting,
  then re-score it automatically. Let the user decide whether to generate a CV
  draft for a posting under review. That choice applies only to that posting.

### Notification digests

- Queue postings that newly become matches or need review, including after a
  settings change or manual correction. Deliver queued entries after the next
  scheduled check. If a posting has a known deadline that is still open and
  less than 48 hours away, send its digest early. Postings with no known
  deadline follow the regular schedule.
- Send separate digests for matches and **Needs review** by email through the
  dedicated Gmail account and show both types in the app. Both can arrive at
  the same time. Skip empty digests.
- Use the posting's latest status at delivery time. Include it in at most one
  digest for the same status change, and do not repeat early entries in the
  scheduled digest.
- Link each entry to its posting in the app. Include the short review reason
  for each **Needs review** entry.
- Apply the repeat notification rules for changed postings in section 2.

### Open decisions for this section

- How individual interests ratings are assigned and how interview answers
  translate into suggested settings.
- Whether the user can request a CV draft for a posting that fails a confirmed
  must-have, and how incomplete postings interact with review and digests.
