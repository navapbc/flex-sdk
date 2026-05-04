# Strata Audit Log

The Strata Audit Log lets you record an immutable trail of what happened in your application — who did what, to which record, and any free-form context — and have those entries roll back atomically with the surrounding domain writes when something fails.

## When to use it

Reach for the audit log when you need a permanent record of an action that:

- Affects a domain record and would benefit from "what changed and why" history (e.g. a case was approved, a form was submitted, a determination was overridden).
- Should be coupled to the success of the underlying work — if the domain write fails, the audit entry should not appear.
- May need to outlive the record it describes (the trail of "this case was deleted" stays queryable even after the case is gone).

For lightweight diagnostic logging that doesn't need to survive a rollback, plain `Rails.logger` is still the right tool.

## Quick start

### Atomic, multi-line writes

`Strata::AuditLog.record` opens an `ActiveRecord::Base.transaction`, yields a log object you append lines to, and commits everything together. If the block raises, every appended line is rolled back along with the caller's domain writes.

```ruby
Strata::AuditLog.record(actor: current_user) do |log|
  case_record.update!(status: :approved)

  log.add_line(
    action: "case.approved",
    subject: case_record,
    data: { previous_status: "pending", reasons: ruleset_output.reasons }
  )

  notification.deliver!
  log.add_line(action: "notification.sent", data: { channel: "email" })
end
```

`record` returns the `Strata::AuditLog` instance with `.lines` populated, so you can inspect the persisted records:

```ruby
result = Strata::AuditLog.record(actor: current_user) { |log| log.add_line(action: "x") }
result.lines.first # => #<Strata::AuditLine action: "x", actor_id: ..., ...>
```

### Single-line writes

For a one-off event that doesn't need to be paired with other writes, use `Strata::AuditLog.write!`. It creates a single line outside any wrapper transaction:

```ruby
Strata::AuditLog.write!(
  action: "user.signed_in",
  actor: current_user,
  data: { ip: request.remote_ip }
)
```

### `add_line` / `write!` parameters

| Field     | Required | Type                    | Notes                                                                              |
| --------- | -------- | ----------------------- | ---------------------------------------------------------------------------------- |
| `action`  | yes      | `String`                | A short event name. Convention: `"<noun>.<verb>"` (e.g. `"case.approved"`).        |
| `subject` | no       | any AR record           | Polymorphic — the record this event is about.                                      |
| `actor`   | no       | any AR record           | Polymorphic — who did it. Falls back to the `actor:` passed to `record`.           |
| `data`    | no       | `Hash` (or `nil`)       | Free-form jsonb payload. `nil` is coerced to `{}`. Defaults to `{}` when omitted.  |

## Querying audit history

Include `Strata::Auditable` in any model that should expose its history:

```ruby
class Case < ApplicationRecord
  include Strata::Auditable
end
```

`Strata::ApplicationForm` already includes it, so any application form subclass gets `audit_lines` for free.

The concern adds a `has_many :audit_lines, as: :subject` association. Combine it with the scopes on `Strata::AuditLine`:

```ruby
case_record.audit_lines.latest_first
case_record.audit_lines.with_action("case.approved")

Strata::AuditLine.by_actor(current_user).latest_first
Strata::AuditLine.for_subject(case_record).with_action("case.updated")
```

Available scopes on `Strata::AuditLine`:

| Scope                    | Returns                                          |
| ------------------------ | ------------------------------------------------ |
| `for_subject(record)`    | Lines whose subject is the given record.         |
| `by_actor(record)`       | Lines whose actor is the given record.           |
| `with_action(name)`      | Lines whose action matches (accepts symbols).    |
| `latest_first`           | Ordered by `created_at` descending.              |

## Installation

The model, concern, and API are shipped by the engine. Only the migration needs to be installed in the host application:

```bash
bin/rails generate strata:audit_log
bin/rails db:migrate
```

The generator copies `db/migrate/<timestamp>_create_strata_audit_lines.rb`. It does **not** scaffold a host-side `AuditLine` subclass — the schema is fixed and host-specific data goes in the jsonb `data` column.

Pass `--skip-migration-check` to suppress the post-generate prompt that asks whether to run `db:migrate` immediately.

## Schema

`strata_audit_lines` (UUID primary key, immutable rows):

| Column         | Type       | Null | Notes                                         |
| -------------- | ---------- | ---- | --------------------------------------------- |
| `id`           | uuid       | no   | `gen_random_uuid()`                           |
| `action`       | string     | no   | What happened.                                |
| `subject_id`   | uuid       | yes  | Polymorphic — paired with `subject_type`.     |
| `subject_type` | string     | yes  |                                               |
| `actor_id`     | uuid       | yes  | Polymorphic — paired with `actor_type`.       |
| `actor_type`   | string     | yes  |                                               |
| `data`         | jsonb      | no   | Defaults to `{}`. Free-form payload.          |
| `created_at`   | datetime   | no   | No `updated_at` — lines are immutable.        |

Indexes:

- `(subject_type, subject_id, created_at DESC)` — serves the dominant read pattern, "most recent lines for this subject," without a sort.
- `(actor_type, actor_id)` — for "what did this actor do."
- `created_at` — for time-window scans.

## Immutability

`Strata::AuditLine#readonly?` returns `true` once a line is persisted, so updates and destroys raise `ActiveRecord::ReadOnlyRecord`:

```ruby
line = Strata::AuditLog.write!(action: "user.signed_in", actor: current_user)
line.update!(action: "tampered") # => ActiveRecord::ReadOnlyRecord
line.destroy                     # => ActiveRecord::ReadOnlyRecord
```

This is application-level enforcement, not a database constraint. A host app that wants harder guarantees can add a `BEFORE UPDATE/DELETE` trigger.

## Gotchas

### 1. Nested transactions become savepoints

If you call `Strata::AuditLog.record` from inside a block that already opened an `ActiveRecord::Base.transaction`, your inner transaction becomes a **savepoint**, not a new top-level transaction.

The practical consequence: `raise ActiveRecord::Rollback` inside your block only rolls back to the savepoint. The outer transaction keeps going and may still commit. If you need the whole unit of work to roll back, raise a real exception (anything other than `ActiveRecord::Rollback`) so it propagates out of the outer transaction too.

```ruby
ActiveRecord::Base.transaction do
  case_record.update!(status: :approved)

  Strata::AuditLog.record(actor: current_user) do |log|
    log.add_line(action: "case.approved", subject: case_record)
    raise ActiveRecord::Rollback # ← only rolls back the inner savepoint!
  end

  # We're still inside the outer transaction here, and case_record.update!
  # is about to commit even though the audit line was discarded.
end
```

### 2. `after_commit` fires only on the outermost commit

If your application attaches `after_commit` callbacks to `Strata::AuditLine` (e.g. to ship lines to an external sink), those callbacks **fire only when the outermost transaction commits**, not when `Strata::AuditLog.record`'s inner block returns. Lines created deep in a nested transaction may take much longer than expected to reach downstream systems. Plan downstream integrations accordingly.

### 3. Audit lines do **not** cascade-destroy with the subject

Unlike `Strata::Determinable`, `Strata::Auditable` deliberately omits `dependent: :destroy`. This is intentional — an audit trail should outlive the record it describes so the history of "this case was deleted" remains queryable. The trade-off is that `audit_line.subject` will return `nil` once the underlying record is gone. The polymorphic `subject_type` and `subject_id` columns are preserved, so you can still query history by class+id even after deletion.

### 4. Polymorphic class name drift

The polymorphic columns store class name **strings** (`"Case"`, `"User"`, etc.). If you rename a host model later, existing `audit_lines` rows still reference the old name. Either avoid renaming audited models, or run a data migration to rewrite `subject_type` / `actor_type` when you do.

### 5. Thread safety

For normal Rails / Puma usage you don't need to think about this — every web request builds its own `Strata::AuditLog` instance, so concurrent requests never share state.

The accumulator returned via `.lines` is **not** thread-safe across threads spawned **inside** the block (`Thread.new { log.add_line(...) }`, `Parallel.map(...) { |x| log.add_line(...) }`). Persisted rows remain correct in that case (Postgres serializes inserts), but the in-memory `.lines` array can be incomplete. If you fan out work inside the block, query `Strata::AuditLine` directly for what was written rather than trusting the returned accumulator.

## Conventions

- **Action names**: short, lowercase, dot-separated noun-then-verb strings — e.g. `"case.approved"`, `"form.submitted"`, `"notification.sent"`. This makes `with_action` filtering predictable and groups related events alphabetically.
- **`data` payloads**: keep them small and structured. Useful contents include `{ before: ..., after: ... }` diffs, rule outputs, request metadata (IP, user agent), or external IDs. Avoid stuffing entire serialized records — the `subject` association already gives you a pointer to the live record.
- **Actor**: pass the AR record (e.g. `current_user`), not just the ID, so the polymorphic association can hydrate it later.
- **System events**: when there's no human actor (background jobs, cron, system boot), pass `actor: nil`. The columns are nullable.
