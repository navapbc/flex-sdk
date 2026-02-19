# Claude Development Guidelines

Guidelines for AI assistants working on this Ruby on Rails application.

## Key References

- **@Makefile** — all common dev commands (`make lint`, `make test`, `make db-migrate`, etc.)
- **@schema.rb** — tables, columns, foreign keys, indexes; this app uses UUID primary keys
- **@RubyOnRails** — Rails docs for ActiveRecord, routing, views, migrations, conventions
- **[docs/README.md](docs/README.md)** — index of all project documentation

## Mandatory Workflow

Follow these steps in order. **Do not skip or reorder.**

1. **Ask clarifying questions** — surface unclear requirements, edge cases, and business rules before doing anything
2. **Discuss design choices** — present implementation options with trade-offs and get approval
3. **Write RSpec tests** — comprehensive coverage including edge cases; **present to user and wait for approval before writing any implementation**. See [testing guidelines](docs/contributing/testing.md).
4. **Implement code** — only after tests are approved; run `make test` frequently
5. **Lint** — run `make lint` and resolve all warnings
6. **Propose refactorings** — identify improvements (duplication, DDD patterns, complexity); **wait for approval before implementing**

## Code Conventions

- Thin controllers — business logic belongs in domain models and service objects
- Use Pundit policy objects for authorization — see [authorization docs](docs/authorization.md)
- Use ActiveRecord associations and scopes; avoid raw SQL when ActiveRecord suffices
- Use strong parameters in controllers
- Follow Rails naming conventions throughout
- See [implementation guidelines](docs/contributing/implementation-guidelines.md) for patterns and examples

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

## SDK Features

When working with SDK-specific features, consult these docs:

| Topic | Doc |
|---|---|
| Available SDK components | [strata-sdk-components.md](docs/strata-sdk-components.md) |
| Strata attributes (Address, Array, MemorableDate, etc.) | [strata-attributes.md](docs/strata-attributes.md) |
| Contributing new Strata attributes | [contributing-strata-attributes.md](docs/contributing/contributing-strata-attributes.md) |
| Data modeler & migration generator | [strata-data-modeler.md](docs/strata-data-modeler.md) |
| Multi-page form builder | [multi-page-form-builder.md](docs/multi-page-form-builder.md) |
| Intake application forms | [intake-application-forms.md](docs/intake-application-forms.md) |
| Rules engine | [strata-rules-engine.md](docs/strata-rules-engine.md) |
| Business process hierarchy | [business-process-family-tree.md](docs/business-process-family-tree.md) |
| Case management business process | [case-management-business-process.md](docs/case-management-business-process.md) |
| Implementing task views | [implementing-tasks-views.md](docs/implementing-tasks-views.md) |
| API authentication | [api-authentication.md](docs/api-authentication.md) |
| Generators | [generators.md](docs/generators.md) |

## Database Commands

```bash
make db-migrate      # Run migrations
make db-rollback     # Rollback last migration
make db-seed         # Seed database
make db-reset        # Reset and reseed
make db-console      # Access database console
```

When generating migrations, use the Rails generator directly:
```bash
cd spec/dummy && bundle exec rails generate migration MigrationName
```

Always use reversible migrations (`change`) or explicit `up`/`down` methods.

## Hard Rules

- Never assume business logic — always ask
- Never write implementation before tests are approved
- Never implement refactorings without approval
- Never modify `schema.rb` directly — use migrations
- Never bypass authorization policies
- Never mix concerns across bounded contexts
