# Creating a Case Management Business Process

After creating an application form, the next step is to define how that application will be processed. In Flex, this is done through a case management business process, which defines the workflow and tasks needed to process the application.

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

- Create a case model in `app/models/flex/passport_case.rb`
- Generate a business process in `app/business_processes/passport_business_process.rb`
- Set up the necessary database migrations
- Create task models and views

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

## Next Steps

1. [Add custom task implementations](../lib/generators/strata/task/USAGE)
