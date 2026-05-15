# Claude Development Guidelines

Guidelines for AI assistants working on the Strata SDK for Rails.

## What this repo is

Strata SDK for Rails is a **Rails engine** (gem name: `strata`, see [strata.gemspec](strata.gemspec)) that provides building blocks for government digital services: form attributes, multi-page form flows, a rules engine, case management, intake applications, audit logging, and more. The engine's code lives at the repo root in `app/`, `config/`, and `lib/`. The engine ships no migrations of its own; all migrations live in the dummy app under `spec/dummy/db/migrate/`.

A **dummy Rails app** lives at [spec/dummy/](spec/dummy/) and is used to exercise the engine in tests and locally. Several things you'd expect at the repo root live there instead:

- Schema: [spec/dummy/db/schema.rb](spec/dummy/db/schema.rb) — UUID primary keys
- Migrations: [spec/dummy/db/migrate/](spec/dummy/db/migrate/)
- Seeds: [spec/dummy/db/seeds.rb](spec/dummy/db/seeds.rb)
- Local env: `spec/dummy/.env` (created from `spec/dummy/local.env.example` when running `make setup`)

Stack: Ruby (pinned in [.ruby-version](.ruby-version)), Rails and runtime gems (declared in [strata.gemspec](strata.gemspec)), Postgres (via Docker Compose, see [spec/dummy/docker-compose.yml](spec/dummy/docker-compose.yml)). Test/lint toolchain: RSpec, RuboCop.

## Key references

- [Makefile](Makefile) — all common dev commands
- [spec/dummy/db/schema.rb](spec/dummy/db/schema.rb) — tables, columns, foreign keys, indexes
- [docs/README.md](docs/README.md) — index of all project documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) — contributor workflow, PR process
- [docs/decisions/](docs/decisions/) — ADRs for major design choices

## First-time setup

```bash
make setup          # installs deps, creates spec/dummy/.env, initializes the DB
```

`make setup` runs `install` (bundler + npm in `spec/dummy`), copies `.env`, and runs `init-db` (starts the DB container, migrates, prepares the test DB, seeds).

## Daily commands

```bash
make start          # start the dummy Rails server (db must be up)
make test           # run the RSpec suite with coverage
make test-watch     # re-run tests on file changes (Guard)
make lint           # run RuboCop with auto-fix
make lint-ci        # run RuboCop without auto-fix (matches CI)
make db-migrate     # run migrations
make db-rollback    # rollback last migration
make db-seed        # seed the DB
make db-reset       # drop, recreate, migrate, seed
make db-console     # open the Rails dbconsole
```

## After pulling or merging changes

Run `make install` to pick up new gem or npm dependencies, then `make db-migrate` if new migrations landed (check `git diff` against `spec/dummy/db/migrate/`). Also run `make db-test-prepare` if the schema changed, so the test DB is in sync before `make test`.

## Before committing or pushing

Run both, and resolve everything before pushing:

```bash
make lint           # must finish clean
make test           # must pass
```

CI runs `lint-ci` and the test suite via [.github/workflows/ci.yml](.github/workflows/ci.yml) — a failed local lint or test will fail CI. If you've changed UI or anything user-facing, also exercise it via `make start` in a browser before declaring the task done.

## Workflow

The full workflow below applies to **non-trivial changes** (new features, behavior changes, anything touching business rules or public APIs). For trivial changes — typo fixes, comment edits, renaming a local variable, fixing a lint warning, updating a doc — skip straight to implementation; you don't need to gate on tests-first approval.

For non-trivial work, follow these steps in order:

1. **Ask clarifying questions** — surface unclear requirements, edge cases, and business rules before doing anything.
2. **Discuss design choices** — present implementation options with trade-offs and get approval.
3. **Write RSpec tests** — comprehensive coverage including edge cases; **present to the user and wait for approval before writing any implementation**. See [testing guidelines](docs/contributing/testing.md).
4. **Implement code** — only after tests are approved; run `make test` frequently.
5. **Lint** — run `make lint` and resolve all warnings.
6. **Propose refactorings** — identify improvements (duplication, DDD patterns, complexity); **wait for approval before implementing**.

When in doubt about whether a change is trivial, ask.

## Execution context

When you are running in GitHub Actions (typically triggered by an `@claude` mention on an issue, PR, or review comment), **additionally** follow [.github/claude-sandbox-instructions.md](.github/claude-sandbox-instructions.md). Those rules cover the CI-specific workflow: post a plan and wait for approval, work on a branch, open a PR with a description, and post-a-comment-then-stop when you hit decisions that need human judgment.

Check `$GITHUB_ACTIONS` (set to `true` in CI) if you're unsure which context you're in. When running locally, ignore the sandbox instructions.

## Migrations

Generate migrations with the Rails generator from inside the dummy app:

```bash
cd spec/dummy && bundle exec rails generate migration MigrationName
```

Always use reversible migrations (`change`) or explicit `up`/`down` methods. Never edit [spec/dummy/db/schema.rb](spec/dummy/db/schema.rb) directly — it's regenerated by `db:migrate`.

## Code conventions

- Thin controllers — business logic belongs in domain models and service objects
- Use Pundit policy objects for authorization — see [authorization docs](docs/authorization.md)
- Use ActiveRecord associations and scopes; avoid raw SQL when ActiveRecord suffices
- Use strong parameters in controllers
- Follow Rails naming conventions throughout
- See [implementation guidelines](docs/contributing/implementation-guidelines.md) for patterns and examples
- See [debugging guide](docs/contributing/debugging.md) when stuck

## Domain Driven Design

Apply DDD consistently. Before marking a feature complete, verify:

- [ ] Code uses ubiquitous language (domain terms, not technical jargon)
- [ ] Business rules live in domain models, not controllers or services
- [ ] Aggregates have clear boundaries; child entities accessed through the aggregate root
- [ ] Services coordinate between aggregates; they don't contain business logic
- [ ] Entities and value objects are clearly distinguished
- [ ] State transitions and invariants are enforced at the model level
- [ ] Tests are written in terms of business scenarios

See [data modeling guidelines](docs/contributing/data-modeling-guidelines.md) for detailed DDD patterns and examples.

## SDK features

When working with SDK-specific features, consult these docs:

| Topic                                                   | Doc                                                                                      |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Available SDK components                                | [strata-sdk-components.md](docs/strata-sdk-components.md)                                |
| Strata attributes (Address, Array, MemorableDate, etc.) | [strata-attributes.md](docs/strata-attributes.md)                                        |
| Contributing new Strata attributes                      | [contributing-strata-attributes.md](docs/contributing/contributing-strata-attributes.md) |
| Data modeler & migration generator                      | [strata-data-modeler.md](docs/strata-data-modeler.md)                                    |
| Form builder                                            | [strata-form-builder.md](docs/strata-form-builder.md)                                    |
| Multi-page form flows                                   | [multi-page-form-flows.md](docs/multi-page-form-flows.md)                                |
| Intake application forms                                | [intake-application-forms.md](docs/intake-application-forms.md)                          |
| Rules engine                                            | [strata-rules-engine.md](docs/strata-rules-engine.md)                                    |
| Business process hierarchy                              | [business-process-family-tree.md](docs/business-process-family-tree.md)                  |
| Case management business process                        | [case-management-business-process.md](docs/case-management-business-process.md)          |
| Implementing task views                                 | [implementing-tasks-views.md](docs/implementing-tasks-views.md)                          |
| Audit log                                               | [strata-audit-log.md](docs/strata-audit-log.md)                                          |
| API authentication                                      | [api-authentication.md](docs/api-authentication.md)                                      |
| Generators                                              | [generators.md](docs/generators.md)                                                      |

## Hard rules

- Never assume business logic — always ask
- Never write implementation before tests are approved (for non-trivial changes)
- Never implement refactorings without approval
- Never modify [spec/dummy/db/schema.rb](spec/dummy/db/schema.rb) directly — use migrations
- Never bypass authorization policies
- Never mix concerns across bounded contexts
- Never push without a clean `make lint` and a passing `make test`
