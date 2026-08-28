# ADR-002: Use a transactional outbox for domain events

## Status

Accepted

## Date

2026-08-28

## Context

Strata originally used `ActiveSupport::Notifications` both for instrumentation
and for domain events that advance a benefits case. A publish called every
subscriber synchronously on the publisher's thread, inside its open database
transaction. The notification existed only on the Ruby call stack: there was
no persisted event, retry, dead letter, or cross-process delivery.

This also coupled domain delivery to global class-object subscriptions. The
engine removed those subscriptions when Zeitwerk unloaded event-manager code,
while host applications registered business processes from
`config.after_initialize`, which runs only at boot. After the first development
reload, business processes could silently stop receiving events.

Several other failure modes were difficult or impossible to diagnose:

- events without a matching transition or target were only debug logged;
- a step could be saved before its side effect failed;
- production logs contained no durable event or correlation identifier;
- version skew during rolling deploys could silently strand a case; and
- external work performed before commit had neither a durable retry nor an
  idempotency key.

Domain events require different guarantees than instrumentation events.

## Decision

Keep `ActiveSupport::Notifications` available for instrumentation, but move
domain workflow delivery to a PostgreSQL transactional outbox.

`Strata::EventManager.publish` retains its public name-and-payload API. It
inserts an immutable `Strata::Event` in the caller's current transaction. The
event commits or rolls back with the domain change that caused it; publishing
does not invoke domain handlers inline.

After commit, a dispatcher passes the event identifier to a router. The
default inline dispatcher requires no queue. An Active Job dispatcher supports
hosts using Sidekiq, Solid Queue, GoodJob, Resque, or another Active Job
adapter, without adding a queue dependency to the gem.

The router keeps registered handler class names as strings and constantizes
them only at dispatch. Host applications register business processes from
`config.to_prepare`, making registration safe across Rails code reloads. There
are no global business-process subscriptions for Zeitwerk to tear down.

Routing creates a `Strata::EventDelivery` for every event, handler, and target
case. A unique database index on that tuple is the idempotency key. Each
delivery records its status, attempts, retry time, and last error. Handler
execution locks and re-reads the target case, applies only a transition defined
for its current step, and commits the step change, side effect, and successful
outcome together. Exceptions roll back the handler
transaction and remain visible for retry.

A recovery sweep claims undispatched events with `FOR UPDATE SKIP LOCKED`.
Retention is explicit rather than assumed: pruning requires either a supplied
window or host configuration, never removes events with non-terminal
deliveries, works in batches, supports dry runs, and records deletion in the
audit log.

The install generator copies the two-table migration into the host
application. Polymorphic target identifiers use strings because the engine
cannot assume the host application's primary-key type.

## Consequences

- Domain events survive request completion and process restarts.
- An event and the state change that caused it have the same transaction
  boundary.
- Each handler outcome is queryable, retryable, and independently idempotent.
- Business-process registration is reload safe and does not retain stale class
  objects.
- Step changes and step side effects share one locked transaction.
- Hosts without a queue can use inline after-commit dispatch; hosts that need
  cross-process durability can use their existing Active Job backend.
- Hosts must install and migrate the outbox tables, and should schedule the
  recovery sweep when process-death recovery is required.
- Event and delivery tables grow until a host chooses and schedules an
  appropriate records-retention policy.
- PostgreSQL is an explicit assumption. The design uses `jsonb`, UUIDs,
  compound indexes, and `FOR UPDATE SKIP LOCKED`.

## Alternatives considered

### Use `config.to_prepare` with the notification bus

This fixes the immediate reload bug but does not provide persistence,
observability, retries, idempotency, or cross-process delivery.

### Rails Event Store

Rails Event Store is mature, but imposing its event API and dependencies on
every engine host would conflict with Strata's existing string-based event DSL.
Guaranteed outbox delivery also requires additional runtime infrastructure.
The dispatcher seam leaves hosts free to integrate another event system when
needed.

### Full event sourcing

Rebuilding case state from an event stream would substantially change the
aggregate model. An outbox supplies the required durability and history while
leaving stored case state authoritative.

### PostgreSQL `LISTEN`/`NOTIFY`

Notifications can reduce latency but are not durable. They do not replace the
outbox or recovery sweep.

### Depend directly on a queue backend

A Sidekiq or Redis dependency would exclude hosts using another Active Job
adapter or no queue. Active Job is already supplied by Rails and provides the
portable boundary the engine needs.
