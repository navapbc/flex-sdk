# Creating a Case Management Business Process

After creating an application form, the next step is to define how that application will be processed. In Strata, this is done through a case management business process, which defines the workflow and tasks needed to process the application.

## Understanding Case Management

A case management business process consists of:

- A case model that tracks the state of the business process
- A sequence of steps that can include:
  - Tasks performed by staff members (such as verifying documents or making determinations)
  - Tasks performed by applicants (such as submitting applications or providing additional information)
  - System processes for automated steps (such as data validation or eligibility calculations)
  - Tasks performed by third parties (such as healthcare providers submitting medical documentation or employers verifying employment)
- Business rules that determine when tasks are available or completed
- Role-based access controls for different types of users

## Creating a new business process

Creating a case management business process involves generating a case model that extends from `Strata::Case` and defining a business process that specifies the workflow. The business process determines how an application moves through your organization, from initial submission to final determination. This guide continues with the passport application example to demonstrate how to create a business process for handling passport applications.

### 1. Generate the Case and Business Process

First, generate the case model and tell the generator which business process
and application form it should use:

```shell
bin/rails generate strata:case PassportCase \
  --business-process PassportBusinessProcess \
  --application-form PassportApplicationForm
```

This command will:

- Create `app/models/passport_case.rb`, its migration, controller, views, and routes
- Generate `app/business_processes/passport_business_process.rb` if it does not exist
- Use the existing `PassportApplicationForm`, or generate it if it does not exist
- Register the generated business process with the event router in `config.to_prepare`

Without the `--business-process` and `--application-form` options, the case
generator prompts before generating either missing class. Staff task classes
are generated separately after the process has been defined.

### 2. Define the Business Process

Update the generated business process file to define your workflow:

```ruby
# app/business_processes/passport_business_process.rb
class PassportBusinessProcess < Strata::BusinessProcess
  # Define steps
  applicant_task('submit_application')

  system_process('verify_identity', ->(kase) {
    IdentityVerificationService.new(kase).verify_identity
  })

  staff_task('review_application', PassportTask)

  # Define start step
  start_on_application_form_created('submit_application')

  # Define transitions
  transition('submit_application', 'PassportApplicationFormSubmitted', 'verify_identity')
  transition('verify_identity', 'IdentityVerified', 'review_application')
  transition('review_application', 'DecisionMade', 'end')
end
```

### 3. Install durable events

Strata uses a transactional outbox for the domain events that advance a case.
Install its tables once in each host application:

```shell
bin/rails generate strata:events
bin/rails db:migrate
```

The business process generator adds a reload-safe registration by class name:

```ruby
config.to_prepare do
  Strata::Events.register "PassportBusinessProcess"
end
```

Registration does not subscribe a class object to a process-global
notification bus. The router stores the name and resolves the current class
when it dispatches an event, so Rails code reloads cannot leave a stale or
missing business process subscriber.

`Strata::EventManager.publish` joins the current Active Record transaction. Put
the domain change and publish call inside the same explicit transaction when
they must commit or roll back atomically:

```ruby
# Both records commit, or neither does.
ApplicationRecord.transaction do
  application.update!(status: :submitted)
  Strata::EventManager.publish(
    "ApplicationSubmitted",
    application_form_id: application.id
  )
end
```

Dispatch starts only after every currently open Active Record transaction
commits. A rollback prevents dispatch. If no transaction is open, the event is
committed and dispatched immediately; publishing after a separate domain
transaction does not make the two writes atomic.

Committed events are processed by `Strata::Events::DispatchJob`, which inherits
the host application's configured Active Job adapter. Applications can use the
inline adapter for synchronous in-process processing or a durable adapter for
cross-process processing:

```ruby
Strata::Events.configure do |config|
  config.max_attempts = 5
  config.retry_base_delay = 1.minute
  config.routing_retry_delay = 5.minutes
  config.retention_days = 90 # optional; no retention window is assumed
end
```

For production, configure a durable backend for the application and run its
worker processes. Strata jobs inherit this setting automatically.

```ruby
# config/environments/production.rb (example)
config.active_job.queue_adapter = :solid_queue
```

`Strata::Events::DispatchJob` routes one committed event and attempts its
handler deliveries sequentially. The event and delivery tables remain the
source of truth. Strata records handler failures and retry times in PostgreSQL
rather than relying on Active Job retry scheduling.

Domain handlers other than business processes can use the same durable path.
Register the class name and expose the event names plus a class-level
`handle_event` (or `call`) method:

```ruby
class ClaimantNotificationHandler
  def self.event_names
    [ "ApplicationApproved", "ApplicationDenied" ]
  end

  def self.handle_event(event)
    NotificationSender.deliver(
      event[:payload],
      idempotency_key: Strata::Events.current_delivery.id
    )
  end
end
```

Add the handler beside the generated business-process registration:

```ruby
# config/application.rb
config.to_prepare do
  Strata::Events.register "ClaimantNotificationHandler"
end
```

During handler execution, `Strata::Events.current_event` and
`Strata::Events.current_delivery` expose durable identifiers that external
services can use as correlation and idempotency keys.

### 4. Generate Staff Task Classes

Generate a task class for each `staff_task` referenced by the process. Do not
generate task records for applicant, third-party, or system-process steps.

```shell
bin/rails generate strata:task Passport
```

This creates `PassportTask`, matching the `staff_task` declaration above. The
task generator accepts one task name; it does not take a case class as a second
positional argument. See [Implementing task views](./implementing-tasks-views.md)
for rendering and interacting with task records.

### 5. Test the Business Process

For a deterministic console check, temporarily use the inline adapter. A
system process executes immediately and may publish another event, so inspect
the reloaded case after the complete event chain rather than assuming the case
will pause on the system step:

```ruby
original_adapter = ActiveJob::Base.queue_adapter
ActiveJob::Base.queue_adapter = :inline

begin
  form = PassportApplicationForm.create!
  kase = PassportCase.find_by!(application_form_id: form.id)

  kase.reload.business_process_instance.current_step
  # => "submit_application"

  form.submit_application
  kase.reload.business_process_instance.current_step
  # => "review_application"
ensure
  ActiveJob::Base.queue_adapter = original_adapter
end
```

With a queued adapter, case creation and transitions are eventually consistent.
Run a queue worker and wait for the relevant dispatch jobs before
looking up or reloading the case; an immediate query may return `nil` or the
previous step.

Domain event history is available through `Strata::Event`, and individual
handler attempts and outcomes are available through `Strata::EventDelivery`.
The dispatch job deliberately does not use Active Job retries. Schedule the
recovery sweep in cron, a platform scheduler, or another recurring-job facility
to process events stranded by process failure and retry due deliveries:

```shell
bin/rails strata:events:sweep
```

Choose an interval no longer than the retry responsiveness your application
requires. Running multiple sweepers is supported; rows are claimed with
`FOR UPDATE SKIP LOCKED`.

Event history is retained until the host chooses a retention window. Pruning
never deletes an event with non-terminal deliveries, retains delivery
idempotency markers until their parent event is removed, audits every committed
deletion batch, and supports a dry run:

```shell
bin/rails generate strata:audit_log # once; pruning requires an audit trail
bin/rails db:migrate
bin/rails "strata:events:prune[90]" DRY_RUN=1
bin/rails "strata:events:prune[90]"
```

Schedule pruning periodically if a retention window is configured. The
`Strata::Events::PruneJob` entry point is also available for a recurring-job
backend.

## Branching and concurrency

A process may define several alternative transitions from one step, keyed by
different event names. Each case stores one `business_process_current_step`,
so it follows only one active path at a time. If competing events arrive for
the same case, the case lock serializes them: the first valid event advances
the case and a later event that is no longer valid is recorded as
`no_transition`.

Parallel fork/join branches are not currently supported. Model independent
parallel work as separate cases or explicit child records and publish a single
event when the required work has joined.

## Next Steps

1. [Add custom task implementations](../lib/generators/strata/task/USAGE)
