# Deferred integrations

These features follow the pasted-posting prototype. The [development harness](../HARNESS.md) defines the prototype scope and change approval process.

## 2. Email access and privacy

Status: approved for writing on 17 November 2026. Open decisions are listed below.

### Mailbox and enabled sources

- The project owner will provide a dedicated Gmail address during email setup.
- Target job alerts from LinkedIn, Duunitori, and Jobly when Gmail intake is
  added after the pasted-posting milestone.
- The user arranges delivery or forwarding of those alerts to this account.
- Connect only the user's dedicated Gmail account during [email onboarding](#email-onboarding).
  Keep their main personal mailbox disconnected.
- Proton Mail is not part of the selected integration.
- Skip messages from sources that are not explicitly enabled.

Feed imported postings into the same assessment and drafting workflow as
pasted postings. Limit email processing to eligible alerts from enabled sources.
Keep unrelated email out of the matching workflow, storage, logs, and AI requests.

### Email onboarding

- When the relevant Google integration is available, let the user connect a
  dedicated Gmail account through Google with the permissions in
  [Access boundary](#access-boundary). Request inbox access when Gmail intake is enabled.
- Let the user choose the digest recipient address. Default to the sign-in
  email and let the user specify a different address. A recipient address
  does not grant mailbox access.
- When Gmail intake is enabled and the required connection is complete,
  record the import-start timestamp and begin checking for eligible alerts
  as described under [Initial import and subsequent checks](#initial-import-and-subsequent-checks).

### Access boundary

- Request the Gmail API's `gmail.send` scope when enabling email digests
  and its `gmail.readonly` scope when enabling alert intake. Use the same
  dedicated account for both features. Send digests only to the configured
  recipient. Do not request permissions to delete, mark messages as read,
  or otherwise modify inbox mail.
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

- Use the alert text for assessment when it contains enough job detail.
- Enable automatic full-text retrieval only for sources where the intended
  automated access and use have been confirmed as permitted. When an eligible
  alert from such a source contains only a preview, try its posting link unless
  the role is already marked **Applied**.
- If retrieval is unavailable, fails, requires login, or yields only partial
  content, mark the posting **Incomplete**. Follow the
  [incomplete posting workflow](../HARNESS.md#incomplete-postings) and show the user this prompt.
  "We couldn't retrieve enough information to assess this role. Add the full
  job posting or review it manually."
- Do not request or use the user's job-site login to complete retrieval.
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
  salary, location, or application deadline. Use the [email digest timing](#email-digests).
- Repeated alerts with unchanged posting content must not generate duplicate
  notifications.
- Preserve existing CV recommendations and cover-letter drafts for user review;
  an updated posting must not silently overwrite them or the user's edits.

### Email retention

- Retain imported email content in the app for 30 days after import, then
  automatically remove that stored content.
- Retention applies only to the app's stored copies. Do not delete or modify
  messages in Gmail.
- Expiring imported email content must not delete the associated job records or
  cause previously processed alerts to be imported again.

### Open decisions for this section

- Supported message templates, source identification rules, and forwarding format.

Writing this section does not connect the Gmail account or authorize reading
live email during harness preparation.

## Email digests

- When email digests are added, send copies of the corresponding in-app
  results. Digest delivery can be enabled separately from Gmail intake.
- Queue postings that newly become matches or need review, including after a
  settings change or manual correction. When scheduled delivery is enabled,
  email queued entries after the next scheduled check. If a posting has a
  known deadline that is still open and less than 48 hours away, send its
  email digest early. Postings with no known deadline follow the regular
  schedule.
- Send separate digests for matches and **Needs review** by email through the
  dedicated Gmail account and show both types in the app. Both can arrive at
  the same time. Skip empty digests.
- Use the posting's latest status at delivery time. Include it in at most one
  digest for the same status change, and do not repeat early entries in the
  scheduled digest.
- Link each entry to its posting in the app. Include the short review reason
  for each **Needs review** entry.
- Once an incomplete posting has enough information to complete the assessment,
  it becomes eligible for the matches or **Needs review** digest.
- Apply the [repeat notification rules for changed postings](#changed-postings-and-repeat-notifications).

## Google Drive backups and restore

### Automated backups and retention

- Let the administrator connect a Google Drive account for backups. Request
  `drive.file` access to manage backup files created by the app. Create
  a private **Job Search Backups** folder in that Drive. This connection
  does not request Gmail access.
- Run an automatic backup once per day on the server, independently of the
  administrator's browser and Mac. Include the app database and saved files.
  Encrypt the backup before uploading it to Drive.
- Keep 30 days of backups in Drive. Keep the recovery key separately from
  the backup files, such as in the administrator's password manager.

### Restore

- Let the administrator download a dated backup directly from Google Drive
  without a running app server.
- Provide a restore command to recover the app on a fresh server using the
  downloaded backup and the recovery key.
- After restoring, sign in and verify that the profile, settings, postings,
  drafts, and application history are available.
