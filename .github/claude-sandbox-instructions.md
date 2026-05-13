# Claude Sandbox Instructions

These rules apply **only when Claude is running in GitHub Actions** (triggered via [.github/workflows/claude.yml](workflows/claude.yml), typically by an `@claude` mention on an issue, PR, or review comment). They layer on top of [CLAUDE.md](../CLAUDE.md) — every rule there still applies.

You can confirm you're in this context by checking that `$GITHUB_ACTIONS == "true"`.

## Workflow for changes

1. **Plan first, then wait for approval.** Post a comment on the triggering issue/PR with:
   - What you'll change and why
   - Files you expect to touch
   - Test approach
   - Any open questions or assumptions
     Then stop. Do not start coding until a human replies with approval (e.g. "go ahead", "lgtm", or answers your questions). If the trigger comment already contains a clear, detailed instruction, you can post a short confirmation plan and proceed once a human acknowledges — but when in doubt, wait.

2. **Work on a branch.** Once approved, create a branch off the appropriate base:
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

You cannot truly pause mid-run in CI, so "stop and ask" means: **post a comment summarizing the situation, list the options you see with trade-offs, and exit without making further code changes.** Do this when you hit:

- An ambiguous business rule that [CLAUDE.md](../CLAUDE.md) says to ask about
- A breaking API or schema change that affects callers outside the changeset
- A failing test whose root cause is unclear, or that you can't reproduce reasoning about
- A decision between two valid implementation paths with materially different trade-offs
- Anything that would require modifying CI, secrets, deployment config, or other shared infra
- A request whose scope is materially larger than the triggering comment implies

A clear "here are the options, please pick" comment is far more useful than a confident wrong direction.

## Communication style

- Be concise. The reader is reviewing a diff, not reading prose.
- Don't reproduce the diff in plan or PR text — link to it.
- If a decision was non-obvious, explain _why_ in one or two sentences. Don't explain _what_.
- Surface anything you skipped, deferred, or are unsure about. Don't hide it at the bottom.
