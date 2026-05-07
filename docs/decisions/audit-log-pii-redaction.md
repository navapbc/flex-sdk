# Design Spec: PII redaction for `Strata::AuditLine#data`

## Status

Decided — not implementing; relying on caller discipline (see Decision below).

## Date

2026-05-06

## Context

`Strata::AuditLine#data` is a free-form `jsonb` column. The audit log API
(`Strata::AuditLog.record` / `.write!` / `#add_line`) accepts whatever hash the
caller passes and persists it verbatim. There is no scrubbing, no allow-list,
and no callback hook for hosts to register a redactor.

This is convenient for the common case ("record what changed") but creates a
realistic privacy hazard: a caller can pass `data: { params: request.params }`,
`data: { user: user.attributes }`, or any similar shorthand and accidentally
persist passwords, session tokens, SSNs, or other PII into a permanent log
that no one routinely audits.

The current docs warn against this in prose, but a documentation rule cannot
prevent the mistake — it only flags it after the fact, and only for callers
who read the docs first.

## Goals

- Give host applications a way to declare *which* attributes on an auditable
  subject should appear in the audit `data` payload, so the audit log captures
  meaningful before/after diffs without leaking everything.
- Keep the API ergonomic. Audit calls today are one-liners; they should remain
  one-liners.
- Make safe behavior the default for hosts that opt in. A host that sets up
  the redaction policy should not have to remember to apply it at every call
  site.
- Out of scope: redacting freeform strings, regex-based scrubbing of unknown
  payloads, encryption-at-rest of `data`. Those are separate concerns.

## Non-goals

- This is **not** a substitute for not putting secrets in `data`. Hosts that
  pass arbitrary `request.params` will still leak — the goal here is to make
  the structured-attribute path safe by default, not to police arbitrary
  hashes.
- This does not retroactively scrub existing audit lines. Hosts that need to
  remediate historical PII must run their own data migration.

## Design options considered

### Option A — Allow list on the subject model (proposed default)

The `Strata::Auditable` concern gains a class-level DSL that declares which
attributes are safe to capture in audit `data`:

```ruby
class Case < ApplicationRecord
  include Strata::Auditable

  audit_attributes :status, :assigned_to_id, :priority
end
```

Two helpers ship alongside it:

- `record.audit_snapshot` — returns `{ "status" => "approved", ... }`, the
  current values of the allow-listed attributes.
- `record.audit_diff` — returns `{ "status" => ["pending", "approved"] }`,
  using ActiveModel::Dirty (or `previous_changes` post-save) restricted to the
  allow-listed attributes.

Callers use these in their `data:` payloads:

```ruby
log.add_line(
  action: "case.approved",
  subject: case_record,
  data: { changes: case_record.audit_diff }
)
```

Anything not listed in `audit_attributes` is *unreachable* through these
helpers, so a future refactor can't accidentally start logging a new PII
field.

**Pros:**
- Safe by default — any attribute not explicitly listed is never logged.
- Self-documenting — reading the model tells you what shows up in audit
  history.
- Small surface area — one class macro, two helper methods.

**Cons:**
- Requires every auditable model to declare its list. New attributes that
  *should* be audited must be added explicitly.
- Doesn't help callers who pass arbitrary hashes (e.g. `data: { ip: ... }`)
  rather than going through `audit_diff` / `audit_snapshot`. That's intentional
  — callers who freeform-construct `data` are responsible for that data.

### Option B — Block list on the subject model

Inverted form: hosts list the attributes they want *excluded*.

```ruby
class User < ApplicationRecord
  include Strata::Auditable

  audit_block_list :password_digest, :ssn, :session_token
end
```

`audit_snapshot` returns all attributes minus the block list.

**Pros:**
- Easier first-time adoption — one line to mark sensitive fields.
- Doesn't require the host to remember every attribute that *should* be
  audited.

**Cons:**
- Unsafe by default. A new column added to the model after the block list was
  written is automatically captured in audit history, even if it carries PII.
  This is precisely the failure mode the feature is meant to prevent.
- Drifts silently: nothing connects "we added this column" to "we should add
  it to the block list."

### Option C — Caller-supplied redactor block

A global registration hook on the audit log:

```ruby
Strata::AuditLog.redact_data do |data|
  data.except("password", "ssn", "token")
end
```

The block runs once per persisted line just before `create!`.

**Pros:**
- Zero per-model boilerplate; one place to define the rule.
- Composes with arbitrary `data` hashes (not just the structured-attribute
  path).

**Cons:**
- Operates on hash keys without knowing semantics — easy to miss a key
  spelled differently (`pw`, `secret`, `auth_token`).
- Centralizes the policy in a place far from the model that owns the data.
  When someone adds a new sensitive field on `User`, they have to remember to
  go edit a global redactor file in a separate part of the app.
- Doesn't help with structured diffs — to use it usefully, callers still need
  to construct `data` themselves.

### Hybrid option (recommended)

Ship **A as the primary mechanism** and leave **C as a separate, opt-in
escape hatch** for hosts that need defense-in-depth on freeform `data`. Skip
B entirely — the unsafe-by-default failure mode disqualifies it.

(See **Decision** below: ultimately the team chose to build none of A/B/C
and rely on caller discipline instead.)

## API sketch

```ruby
module Strata
  module Auditable
    extend ActiveSupport::Concern

    included do
      has_many :audit_lines, as: :subject, class_name: "Strata::AuditLine"
      class_attribute :_audit_attributes, default: []
    end

    class_methods do
      # Declare which attributes are safe to include in audit `data` payloads.
      # Anything not listed here is unreachable via `audit_snapshot` /
      # `audit_diff`.
      def audit_attributes(*names)
        self._audit_attributes = (_audit_attributes + names.map(&:to_s)).uniq
      end
    end

    # Current values of allow-listed attributes.
    def audit_snapshot
      attributes.slice(*self.class._audit_attributes)
    end

    # Per-attribute changes for allow-listed attributes only.
    # Use during/after an update.
    def audit_diff
      changes = saved_changes.presence || changes_to_save
      changes.slice(*self.class._audit_attributes)
    end
  end
end
```

Optional global redactor (Option C, additive):

```ruby
module Strata
  class AuditLog
    class << self
      attr_accessor :data_redactor # ->(hash) { ... }
    end
  end
end

# In add_line / write!, before create!:
data = data || {}
data = self.class.data_redactor.call(data) if self.class.data_redactor
```

## Migration path

1. Land `audit_attributes` DSL + helpers as additive non-breaking change. No
   existing call sites change.
2. Add a doc section showing the `audit_diff` / `audit_snapshot` pattern.
3. (Future) flag direct `record.attributes` usage in the data payload as a
   smell during code review. Not enforced programmatically.

## Open questions

1. Should `audit_attributes` raise when a listed attribute does not exist on
   the model (typo guard), or should it silently ignore? Lean toward raising
   at class definition time.
2. Should `audit_diff` use `previous_changes` (post-save) by default, or
   `changes_to_save` (pre-save)? Probably both: `audit_diff(:before_save)` vs
   `audit_diff(:after_save)`, with `:after_save` as the default since most
   audit calls happen post-update.
3. How does this interact with strata attributes (Address, MemorableDate,
   etc.) that span multiple columns? Probably needs a follow-up: the macro
   should accept a `Strata::Attribute` name and expand it to the underlying
   column set.
4. Out-of-scope but worth filing: should there be a query-time redaction for
   audit lines that already exist? E.g. a host could install a per-subject
   `audit_render(line)` hook that the dummy view (and any host viewer) calls
   before displaying `data`.

## Decision

After discussion with the team, we are **not implementing the redaction
mechanism described above at this time**. This may be considered in the future
depending on feedback from users.

The working agreement is:

- Engineers calling `Strata::AuditLog.record` / `.write!` / `#add_line` are
  responsible for **self-screening any value passed to `data:`** for PII
  before persistence. There is no automatic redaction; whatever the caller
  hands the API ends up in a permanent, immutable log.
- The user-facing audit log README ([docs/strata-audit-log.md](../strata-audit-log.md))
  explicitly calls out this responsibility so future contributors and AI
  agents see it at the API surface, not buried in a decision doc.
- This decision is **revisitable**. If a host application onboards a
  higher-sensitivity workload, or we observe leaks in practice, option A
  (allow list DSL) remains the recommended implementation path.

## Tracking

This document is the design baseline for a feature we considered and decided
**not** to build. If the decision above is reversed, implementation should
land as a separate PR with its own tests, docs update, and migration story
for hosts that have already adopted `Strata::Auditable`.
