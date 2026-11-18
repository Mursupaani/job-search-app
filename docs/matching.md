# Job matching

The [development harness](../HARNESS.md) defines the prototype workflow and change approval process.

Status: approved for writing on 18 November 2026.

## Guided preferences

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

## Setup interview and scoring settings

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
- Offer a short follow-up interview when a posting introduces a relevant
  new factor or the assessment needs an answer about the user's experience
  or preferences. Recognize equivalent wording so the app can reuse an
  existing answer. Save confirmed experience in the career profile and
  confirmed preferences in settings for future assessments.
- For preference questions, offer **No preference** and **I'm not sure yet**.
  Treat unanswered or undecided factors as **Unknown** and flag them for
  review when they could change the outcome.

## Skills scoring

- Show **Technical skills** and **Professional skills** separately in the
  profile and let users filter by category. Apply the same scoring rules to
  both. The posting determines whether a requirement is essential or a bonus.
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

## Preference weights

- For each interests or practical fit preference, multiply its signed value
  from the [interview scale](#guided-preferences) by an adjustable, nonnegative
  decimal multiplier. The multiplier starts at 1.0, so the starting signed
  weights are 1.0, 0.5, -0.5, and -1.0 for the four active preference levels.
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

## Interests scoring

- During the setup interview, ask how much day-to-day work, role, and industry
  matter to the user. Suggest a decimal weight for each and briefly explain the
  suggestions. Let the user adjust the weights before confirming them.
- Assign each interest preference to one of three dimensions. **Day-to-day
  work** covers activities like building features and reviewing code. **Role**
  covers responsibilities, autonomy, and opportunities to grow, such as
  mentorship. **Industry** covers the kinds of products, problems, or sectors
  the user wants to work on.
- Rate each preference from 0.0 to 1.0 and explain the rating using details
  from the posting. Calculate each dimension's score as the weighted average
  of its preference ratings. Calculate the overall interests score as the
  weighted average of the dimension scores using the dimension weights.
- Default to 1.0 for a clear fit, 0.5 for a partial fit, and 0.0 for a
  clear mismatch across all three dimensions. If there is too little
  information to assign a rating, mark it **Unknown**.
- Let the user edit the three decimal ratings in **Matching settings**.
  Require each value to stay within 0.0 to 1.0. A clear fit must score at
  least as high as a partial fit, and a partial fit at least as high as a
  clear mismatch.
- Exclude preferences marked **No preference** or weighted zero. Exclude
  dimensions with no active preferences or a weight of zero. If no active
  dimension remains, show **Not applicable** and skip the interests minimum.
  If an active preference is unclear, show a score range and flag it for
  review if the uncertainty could change whether the posting qualifies.

## Practical fit scoring

- Rate practical preferences from 0.0 to 1.0. Use the setup interview to
  identify the factors that matter to the user and suggest preference levels.
  Calculate practical fit as the weighted average of those ratings.
- Leave practical factors marked **No preference** or weighted zero out of
  the calculation. If no active factors remain, show **Not applicable**
  and skip the practical fit minimum.
- Include a benefit in practical fit scoring when the user has an active
  preference about it.
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

## Matching settings

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
- When the user updates approved career facts, preferences, or scoring settings,
  automatically re-score saved postings they have yet to apply to.
- Save the rating and supporting evidence for each assessed criterion. When
  only a weight or cutoff changes, use the saved ratings to recalculate scores
  or qualification locally. Reassess a criterion when a new fact changes the
  evidence used to rate it.
- Keep existing scores for postings marked **Applied** and preserve existing
  drafts regardless of application status.

## Qualification and review

- Use AI to identify requirements and suggest individual ratings. Show the
  relevant evidence from the posting and the approved profile fact or
  preference behind each rating when available. Calculate the final scores
  in application code using those ratings and the saved scoring settings.
- Score skills, interests, and practical fit separately and explain each score.
  Evaluate the whole posting before applying the qualification and review rules.
  A posting qualifies automatically when at least one category has a usable
  score, all applicable scores meet their minimums, and no review rule applies.
  If the posting has enough text to assess but no category has a usable score,
  put it in **Needs review**.
- A mismatch on any single preference, including one marked 1.0 or -1.0,
  affects its category score without independently blocking a match. Call out
  mismatches with strong preferences in the score explanation.
- Mark an individual criterion **Unknown** when missing, vague, or conflicting
  information prevents a clear comparison with the approved career profile or
  preferences. Mark a clear mismatch **Doesn't meet**. Keep postings with only
  partial text **Incomplete** as described in the [harness](../HARNESS.md#incomplete-postings).
- Put an otherwise promising posting in **Needs review** if an unknown could
  change whether it qualifies. Show other unknowns in the score explanation.
- Also put a posting in **Needs review** when exactly one score falls below its
  minimum and every other applicable score passes. Apply this rule equally to
  skills, interests, and practical fit.
- Also put a posting in **Needs review** when its interests score meets the
  minimum but its skills score falls short, even if practical fit also falls
  short. Explain what makes the role interesting and where the user's
  experience falls short.
- Mark an assessed posting **Below minimums** when neither **Match** nor
  **Needs review** applies. Keep it searchable in **All postings** with its
  scores and explanations. Do not send a notification or generate drafts
  automatically for this outcome.
- Give each **Needs review** posting a short summary explaining why review is
  needed. Identify what needs checking or show the score that fell short, its
  minimum, and the reason for the shortfall.
- Treat missing details about the job as **Unknown** until the user can
  confirm them. Save confirmed job details on the posting and re-score it
  automatically. For **Match** and **Needs review** postings, follow the
  [explicit drafting choices](../HARNESS.md#drafting-and-review).
