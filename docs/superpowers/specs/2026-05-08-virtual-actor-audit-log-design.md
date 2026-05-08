# Virtual Actor Support for Audit Log

**Date:** 2026-05-08  
**Branch:** baonguyen/add-audit-log  
**Status:** Approved

## Problem

`Strata::AuditLine` stores the actor via a polymorphic AR association (`actor_id uuid`, `actor_type string`). This works for AR records (e.g., a `User`) but breaks for non-AR system actors. A host app may have a Ruby class like `Api::Client` that represents "the system made this change" — it has no database record and therefore no UUID to store in `actor_id`.

Two failure modes with the current implementation:
- **Write side:** AR tries to read `actor.id` (nil) and `actor.class.name` for the polymorphic assignment. Result: `actor_id = nil`, `actor_type` set — indistinguishable from a deleted AR record.
- **Read side:** `audit_line.actor` triggers `Api::Client.find(nil)` which raises or returns nil with no way to recover the original intent.

## Design

### No database migration required

Virtual actors reuse the existing `actor_id uuid` (left nil) and `actor_type string` (stores class name) columns. The `Strata::VirtualActor` module marker distinguishes a virtual actor from an AR actor whose record was deleted — both have `actor_id = nil`, but only the virtual actor's class includes `VirtualActor`.

### New components

#### `Strata::VirtualActor` module

A marker module host apps include in any non-AR actor class. No methods required.

```ruby
# Host app
class Api::Client
  include Strata::VirtualActor
end
```

#### `Strata::VirtualActor::Instance`

An immutable value object returned by `AuditLine#actor` when the actor is virtual.

| Method | Returns |
|--------|---------|
| `#actor_type` | `"Api::Client"` |
| `#display_name` | `"Client"` (demodulized, humanized) |
| `#==(other)` | true if `other` is also a `VirtualActor::Instance` with the same `actor_type` |

**Note on identity:** virtual actors are identified by class name only. Any per-instance state (`Api::Client.new(request_id: 123)`) is discarded on persist — the round-trip from `actor=` to `actor` returns a fresh `VirtualActor::Instance`, not the original object. Host apps that need to capture per-event metadata about a virtual actor should put it in `data:`.

### Write side — `AuditLine#actor=`

Overrides the AR association setter. If the assigned object's class includes `Strata::VirtualActor`, stores `actor_type` and sets `actor_id = nil`. Otherwise delegates to `super` (normal AR polymorphic behavior).

```ruby
def actor=(value)
  return super if value.nil?

  klass = value.is_a?(Class) ? value : value.class
  if klass.include?(Strata::VirtualActor)
    self.actor_type = klass.name
    self.actor_id   = nil
  else
    super
  end
end
```

Nil falls through to `super` so AR clears both `actor_id` and `actor_type` as it would for a normal polymorphic association. Passing a class (`Api::Client`) or an instance (`Api::Client.new`) is treated equivalently — both write the same row.

`AuditLog.record(actor: Api::Client.new)` and `AuditLog.write!(actor: Api::Client.new, ...)` require no changes — they pass the actor object through to `AuditLine#actor=`.

### Read side — `AuditLine#actor`

Overrides the AR association reader. Falls through to `super` (normal AR lookup) unless `actor_id` is nil and `actor_type` is present. In that case, uses `safe_constantize` to resolve the class and checks for `VirtualActor` inclusion.

```ruby
def actor
  return super unless actor_type.present? && actor_id.nil?

  klass = actor_type.safe_constantize
  return nil unless klass&.include?(Strata::VirtualActor)

  Strata::VirtualActor::Instance.new(actor_type: actor_type)
end
```

Nil-handling matrix:

| `actor_id` | `actor_type` | Class includes `VirtualActor`? | Returns |
|------------|-------------|-------------------------------|---------|
| present | present | — | AR lookup (unchanged) |
| nil | absent | — | `nil` (unchanged) |
| nil | present | no | `nil` (deleted AR record, graceful) |
| nil | present | yes | `VirtualActor::Instance.new(actor_type:)` |

### `by_actor` scope

`where(actor: actor)` generates `WHERE actor_type = ? AND actor_id = ?`. For virtual actors, `actor_id = nil` requires `IS NULL`. Rails generates `IS NULL` correctly when given `nil`. The scope must accept three input shapes — an AR record, a virtual actor class or instance, or a `VirtualActor::Instance` returned by a previous read — and route each to the right query:

```ruby
scope :by_actor, ->(actor) do
  case actor
  when Strata::VirtualActor::Instance
    where(actor_type: actor.actor_type, actor_id: nil)
  else
    klass = actor.is_a?(Class) ? actor : actor.class
    if klass.include?(Strata::VirtualActor)
      where(actor_type: klass.name, actor_id: nil)
    else
      where(actor: actor)
    end
  end
end
```

This makes `AuditLine.by_actor(line.actor)` symmetric with `AuditLine.by_actor(Api::Client.new)` — both find the same rows.

## Files to change

| File | Change |
|------|--------|
| `app/models/strata/audit_line.rb` | Override `actor=`, `actor`, update `by_actor` scope |
| `app/models/strata/virtual_actor.rb` | New — `VirtualActor` module + `Instance` value object |
| `spec/models/strata/audit_line_spec.rb` | Add virtual actor write/read/scope specs |
| `spec/factories/strata/strata_audit_line_factory.rb` | Add virtual actor trait |

No migration. No changes to `AuditLog`, `Auditable`, or host app contracts beyond adding `include Strata::VirtualActor`.

## Out of scope

- Multiple distinguishable virtual actor instances (type name is sufficient for all known use cases)
- `Strata::VirtualActor` on the subject side
- Virtual actor display in UI views (host app concern)

## Rejected alternatives

| Alternative | Why not |
|---|---|
| Add an `actor_kind` enum column (`'ar' \| 'virtual'`) to disambiguate explicitly instead of inferring from `actor_id IS NULL` + `VirtualActor` inclusion | Requires a migration and backfill on existing rows. The marker-based inference is unambiguous given the four-cell nil-handling matrix above; the explicit column adds schema churn for no behavior change. |
| Store virtual actor identity inside the `data` JSON column and leave `actor_*` columns AR-only | Cleaner separation of polymorphic-AR vs system actors, but `by_actor` would no longer be a single indexed query — it would need a JSON predicate. Loses the goal of treating virtual actors as first-class for filtering and display. |
| Single sentinel "system" AR row with a fixed UUID | Works for one logical actor but doesn't scale to multiple distinct system actors (e.g. `Api::Client`, `Cron::Worker`). Also leaves a real DB row that other tables might foreign-key to, which is the wrong shape for a non-persistent identity. |
