# Job Search App — Development Harness

Build this harness one section at a time. Discuss and refine each section with the
user before writing it. Write or revise a section only when the user explicitly
instructs you to do so. Unresolved decisions must remain explicit rather than
being filled in as approved requirements.

## 1. Scope and operating environment

Status: approved for writing on 17 November 2026.

### Purpose and users

Build a personal job-search web app that helps the user identify suitable
positions and prepare applications. The initial user is the project owner.
Keep a path to adding users later, with records associated with their owning
account from the beginning. Public registration is disabled initially.

### Supported inputs

- LinkedIn job-alert emails from the user's email account.
- Job postings pasted directly into the app as text.

Email processing is limited to LinkedIn job alerts. Unrelated email must not be
read into the matching workflow, stored, logged, or sent to an AI provider.
The email provider, integration method, and how this boundary is enforced will
be decided in a later section. Whole-mailbox access is not implicitly approved
by this requirement.

### Initial capabilities

- Compare each posting against the user's skills, interests, and practical
  requirements, showing separate scores and explanations.
- Notify the user when the configured matching thresholds are met.
- Recommend CV changes and draft a cover letter for qualifying positions.
- Draft cover letters in Finnish or English according to the posting's language.
- Present CV recommendations and cover letters for the user's review.

The user's career profile, interests, practical requirements, scoring rules,
thresholds, notification channel, and handling of incomplete or mixed-language
postings will be specified in later sections. No personal qualifications or
preferences should be invented to fill these gaps.

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
- Once deployed to an always-on host, check for LinkedIn alerts at least daily,
  independently of the user's Mac and without an open browser.

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
