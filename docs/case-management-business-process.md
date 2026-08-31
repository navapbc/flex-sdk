# Creating a Case Management Business Process

After creating an application form, the next step is to define how that application will be processed. In Strata, this is done through a case management business process, which defines the workflow and tasks needed to process the application.

## Understanding Case Management

A case management business process consists of:

- A case model that tracks the state of the business processs
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

First, generate the case model and business process files:

```shell
bin/rails generate strata:case PassportCase
```

This command will:

- Create a case model in `app/models/strata/passport_case.rb`
- Generate a business process in `app/business_processes/passport_business_process.rb`
- Set up the necessary database migrations
- Create task models and views
- Register the business process with the event router in `config.to_prepare`

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

Calling `Strata::EventManager.publish` writes an event in the same database
transaction as the change that caused it. After that transaction commits, the
router creates per-handler deliveries and dispatches them. The default inline
dispatcher needs no queue; applications that need cross-process delivery can
select the Active Job dispatcher and use their existing queue backend.

```ruby
Strata::Events.dispatcher = Strata::Events::Dispatcher::ActiveJob.new

Strata::Events.configure do |config|
  config.max_attempts = 5
  config.retry_base_delay = 1.minute
  config.routing_retry_delay = 5.minutes
  config.retention_days = 90 # optional; no retention window is assumed
end
```

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

Strata::Events.register "ClaimantNotificationHandler"
```

During handler execution, `Strata::Events.current_event` and
`Strata::Events.current_delivery` expose durable identifiers that external
services can use as correlation and idempotency keys.

### 4. Generate Task Views

For each task in your business process, generate the necessary views:

```shell
bin/rails generate strata:task verify_identity PassportCase
bin/rails generate strata:task review_documents PassportCase
bin/rails generate strata:task process_payment PassportCase
bin/rails generate strata:task make_determination PassportCase
```

### 5. Test the Business Process

Test your business process in the Rails console:

```ruby
form = PassportApplicationForm.create
kase = PassportCase.find_by(application_form_id: form.id)

kase.business_process_instance.current_step
# => "submit_application"

form.submit_application
kase.business_process_instance.current_step
# => "verify_identity"
```

Domain event history is available through `Strata::Event`, and individual
handler attempts and outcomes are available through
`Strata::EventDelivery`. A recovery sweep can redispatch committed events that
were not dispatched before a process stopped:

```shell
bin/rails strata:events:sweep
```

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

## Next Steps

1. [Add custom task implementations](../lib/generators/strata/task/USAGE)
