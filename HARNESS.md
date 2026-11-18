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
- Process newly received or unprocessed eligible alerts during checks. Do not
  poll saved postings for changes.
- Consolidate repeated appearances of the same position, including appearances
  across supported sources, into one job record. Preserve source references.

### Full posting retrieval and incomplete alerts

- When an eligible alert contains only a preview, automatically try to retrieve
  the full job description from its posting link, unless the alert is already
  identified as a role marked **Applied**.
- If retrieval fails, requires login, or still yields only partial content,
  mark the posting **Incomplete** and show it in the app with this prompt:
  "We couldn't retrieve enough information to assess this role. Add the full
  job posting or review it manually."
- Do not request or use the user's job-site login to complete retrieval.
- Let the user review the available details in the existing record or add the
  full posting to that record. Evaluate the completed description.
- Keep the incomplete status visible until sufficient posting text is available.
  Any assessment based on partial content must be identified as incomplete.
- Treat retrieved page content as source data, with the same instruction boundary
  as email content.

### Changed postings and repeat notifications

- If a new alert is identified as a role marked **Applied**, skip fetching the
  posting and skip AI scoring and drafting. Preserve the application record,
  including its status and score, and exclude the alert from both digests.
- When updated content for an existing posting that is not marked **Applied**
  is detected during import or retrieval, update the existing job record and
  automatically re-score it.
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
- Use the same labeled preference scale in the interview and settings:
  - `1.0` — **Strongly prefer to have**
  - `0.5` — **Nice to have**
  - `0.0` — **No preference**
  - `-0.5` — **Prefer to avoid**
  - `-1.0` — **Strongly prefer to avoid**
- Keep these preference values separate from the posting's fit ratings, which
  range from 0.0 to 1.0. Leave criteria marked **No preference** out of scoring.
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
  application language selected under section 5. Use the posting's terminology
  where it accurately reflects the user's skills and experience.
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

Status: approved for writing on 18 November 2026.

### Setup interview and scoring settings

- During setup, interview the user about their skills, interests, and practical
  requirements. Suggest starting minimums for skills, interests, and practical
  fit directly from the interview answers, without requiring a separate round
  of rating sample postings.
- Ask how close a fit a posting should be to qualify automatically for each
  category. Map **Open to a stretch** to 0.5, **Solid match** to 0.7,
  **Close match** to 0.85, and **Exact match** to 1.0. Apply the same mapping
  separately to each category.
- Show the three suggested minimums and briefly explain each suggestion. Let
  the user adjust any minimum before confirming it and edit it later in
  **Matching settings**.
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
  score and do not independently disqualify a posting.

### Preference weights

- For each interests or practical fit preference, multiply its signed value
  from section 3 by an adjustable, nonnegative decimal multiplier. The
  multiplier starts at 1.0, so the starting signed weights are 1.0, 0.5,
  -0.5, and -1.0 for the four active preference levels.
- Use the sign of the preference to determine what earns a higher fit rating.
  For a negative preference, avoiding the criterion earns a higher rating.
  Use the absolute value of the signed weight in the weighted average, both
  when weighting the fit rating and when summing the weights. Leave
  **No preference** out of scoring.
- Let the user edit the multiplier in **Matching settings** to change how
  much the criterion counts without changing whether they want or avoid it.
- Before saving, compare the final weight magnitudes within each direction.
  A mild preference may equal the weight of a strong preference in the same
  direction but may not exceed it. Apply this rule to preferences both to
  have and to avoid. If the rule fails, prevent saving, explain which weights
  conflict, and show the highest multiplier allowed for the mild preference.

### Interests scoring

- During the setup interview, ask how much day-to-day work, role, and industry
  matter to the user. Suggest a decimal weight for each and briefly explain the
  suggestions. Let the user adjust the weights before confirming them.
- Rate day-to-day work, role, and industry from 0.0 to 1.0 and explain each
  rating using details from the posting. Calculate the interests score as the
  sum of the weighted ratings divided by the sum of the included weights.
- Default to 1.0 for a clear fit, 0.5 for a partial fit, and 0.0 for a
  clear mismatch across all three dimensions. If there is too little
  information to assign a rating, mark it **Unknown**.
- Let the user edit the three decimal ratings in **Matching settings**.
  Require each value to stay within 0.0 to 1.0. A clear fit must score at
  least as high as a partial fit, and a partial fit at least as high as a
  clear mismatch.
- Leave dimensions marked **No preference** out of the calculation. If every
  interests dimension is marked **No preference**, show the interests score
  as **Not applicable** and skip its minimum for qualification. If a dimension
  matters to the user but the posting leaves it unclear, show a score range
  and flag it for review if the uncertainty could change whether the posting
  qualifies.

### Practical fit scoring

- Rate practical preferences from 0.0 to 1.0. Use the setup interview to
  identify the factors that matter to the user and suggest preference levels.
  Calculate practical fit as the weighted average of those ratings.
- Let the user set both a preferred target and a zero-score point for the same
  numeric criterion. Give 1.0 at the preferred target or better and reduce
  the rating linearly to 0.0 at the zero-score point. Less favorable values
  also earn 0.0 for that criterion.
- For categories such as work arrangement, use editable ratings suggested by
  the interview. For a user who prefers on-site work, a hybrid role with
  confirmed daily office access earns 1.0 for work arrangement.
- If a hybrid posting leaves daily office access unclear and the user prefers
  on-site work, offer two choices in **Matching settings**. **Pass** gives
  work arrangement 1.0 and explains the assumption. **Needs review** flags
  the posting and asks the user to confirm office access.
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

- Score skills, interests, and practical fit separately and explain each score.
  Evaluate the whole posting before applying the qualification and review rules.
  A posting qualifies automatically when all applicable scores meet their
  minimums and no review rule applies.
- A mismatch on any single preference, including one marked 1.0 or -1.0,
  affects its category score without independently blocking a match. Call out
  mismatches with strong preferences in the score explanation.
- Mark an individual criterion **Unknown** when missing, vague, or conflicting
  information prevents a clear comparison with the approved career profile or
  preferences. Mark a clear mismatch **Doesn't meet**. Keep postings with only
  partial text **Incomplete** as described in section 2.
- Put an otherwise promising posting in **Needs review** if an unknown could
  change whether it qualifies. Show other unknowns in the score explanation.
- Also put a posting in **Needs review** when exactly one score falls below its
  minimum and every other applicable score passes. Apply this rule equally to
  skills, interests, and practical fit.
- Also put a posting in **Needs review** when its interests score meets the
  minimum but its skills score falls short, even if practical fit also falls
  short. Explain what makes the role interesting and where the user's
  experience falls short.
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
- Keep **Incomplete** postings visible in the app as described in section 2.
  They become eligible for the matches or **Needs review** digest once there
  is enough information to complete the assessment.
- Apply the repeat notification rules for changed postings in section 2.

## 5. Cover letters

Status: drafting, consistency checks, and language rules approved on
18 November 2026.

### Drafting and review

- Generate the tailored CV and cover letter together when a posting qualifies
  or when the user chooses to proceed with a **Needs review** posting.
- Use only facts supported by the user's approved career profile. The cover
  letter may expand on relevant examples that the tailored CV leaves out.
- Before presenting the drafts for review, check each draft against the
  approved profile and cross-check the two drafts against each other. Check
  claims about dates, titles, qualifications, skills, and responsibilities.
- Show the relevant passages together when the drafts conflict and ask the
  user to resolve the discrepancy. If either draft is edited, run the check
  again and flag any new conflicts for the user to resolve.

### Application language

- Use the same language, Finnish or English, for the tailored CV and cover
  letter. Follow any explicit application language specified in the posting.
- If the posting gives no language instruction, use the language of the main
  job description. If it is evenly split between Finnish and English, ask the
  user to choose before drafting.
- Let the user change the language for both drafts during review.
