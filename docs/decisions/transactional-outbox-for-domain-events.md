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

Domain events require durable delivery guarantees.

## Decision

Replace the process-local notification bus with a PostgreSQL transactional
outbox for domain workflow delivery.

`Strata::EventManager.publish` retains its public name-and-payload API. It
inserts an immutable `Strata::Event` in the caller's current transaction. The
event commits or rolls back with the domain change that caused it; publishing
does not invoke domain handlers inline.

After commit, an Active Job receives the event identifier and passes it to the
router. Strata jobs inherit the host application's Active Job adapter, whether
that is the built-in inline or async adapter, Sidekiq, Solid Queue, GoodJob,
Resque, or another backend.

The router keeps registered handler class names as strings and constantizes
them only at dispatch. Host applications register business processes from
`config.to_prepare`, making registration safe across Rails code reloads. There
are no global business-process subscriptions for Zeitwerk to tear down.

Routing creates a `Strata::EventDelivery` for every event, handler, and target
case. The dispatch job then attempts those deliveries sequentially. A unique
database index on that tuple is the idempotency key. Each
delivery records its status, attempts, retry time, and last error. Handler
execution locks and re-reads the target case, applies only a transition defined
for its current step, and commits the step change, side effect, and successful
outcome together. Exceptions roll back the handler
transaction and remain visible for retry.

A recovery sweep processes each due event or delivery in its own
`FOR UPDATE SKIP LOCKED` transaction. A failure rolls back only that record's
work, so one poison record cannot disable the rest of the sweep. Unrecognized
events are deferred before another routing attempt. Persisted failed deliveries
are retried directly rather than reconstructed from current router output.
Adapter-native retries are disabled; persisted retry timestamps and the sweeper
remain authoritative.
Retention is explicit rather than assumed: pruning requires either a supplied
window or host configuration, never removes events with non-terminal
deliveries, keeps delivery idempotency markers for the lifetime of their event,
works in batches, supports dry runs, and atomically records an audit line for
each deletion batch.

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
- Strata inherits the host application's Active Job adapter rather than owning
  separate queue configuration.
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
The Active Job seam leaves hosts free to select their existing job backend.

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
