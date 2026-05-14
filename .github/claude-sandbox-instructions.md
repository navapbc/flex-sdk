# Claude Sandbox Instructions

These rules apply **only when Claude is running in GitHub Actions** (triggered via [.github/workflows/claude.yml](workflows/claude.yml), typically by an `@claude` mention on an issue, PR, or review comment). They layer on top of [CLAUDE.md](../CLAUDE.md) — every rule there still applies.

You can confirm you're in this context by checking that `$GITHUB_ACTIONS == "true"`.

## Workflow for changes

1. **Post a plan and wait for approval.** Comment on the triggering issue/PR with:
   - What you'll change and why
   - Files you expect to touch
   - Test approach
   - Any open questions or assumptions

   Then stop and wait. Do not start coding until a human replies with approval. **The reply must mention `@claude`** (e.g. `@claude go ahead`, `@claude lgtm`) — the workflow only fires on comments containing that mention, so a bare "go ahead" will not re-trigger a run. Once approved, proceed through the rest of the workflow autonomously — you do not need further sign-off for individual decisions along the way unless you hit one of the items in "When to stop and ask" below.

2. **Work on a branch.** Create a branch off the appropriate base:
   - Issue trigger → branch off the default branch
   - PR/review trigger → branch off the PR's head branch

   Use a descriptive name like `claude/<short-description>`. Never push directly to `main`.

3. **Implement.** Follow every rule in [CLAUDE.md](../CLAUDE.md).

4. **Verify before pushing.** Run `make lint` and `make test`. Resolve every failure. Never push a branch with failing lint or tests.

5. **Open a PR with a real description.** Title summarizes the change in under 70 chars. Body follows [PR template](./pull_request_template.md) and also includes:
   - **Open questions** — anything you decided but want human review on
   - A link back to the triggering issue or comment

## Main branch

**Never** commit, push, or merge changes to the `main` branch. All work must be done on a separate branch. Only humans may commit, push, or merge changes to `main`.

## When to stop and ask

Only stop for **major** items that genuinely require human judgment. For everything else, make a reasoned choice, document it in the PR description, and let code review catch any disagreement.

You cannot truly pause mid-run in CI, so "stop and ask" means: **post a comment summarizing the situation, list the options you see with trade-offs, and exit without making further code changes.** Do this when you hit:

- A business rule you can't infer from existing code, tests, or the triggering comment
- A breaking API or schema change that affects callers outside the changeset
- A failing test you cannot diagnose after reasonable investigation
- Anything that would require modifying CI, secrets, deployment config, or other shared infra
- A request whose scope is materially larger than the triggering comment implies

A clear "here are the options, please pick" comment is far more useful than a confident wrong direction — but reserve it for the items above, not every fork in the road.

## Communication style

- Be concise. The reader is reviewing a diff, not reading prose.
- Don't reproduce the diff in plan or PR text — link to it.
- If a decision was non-obvious, explain _why_ in one or two sentences. Don't explain _what_.
- Surface anything you skipped, deferred, or are unsure about. Don't hide it at the bottom.
