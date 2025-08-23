# Creating Application Forms

This guide will walk you through creating application forms for your digital service using the Flex SDK. When implementing government digital services, the intake process is typically a good place to start, and application forms are the foundation of most intake processes.

## What is an Application Form?

Application forms implement the intake process of government digital services. In domain language, these forms might be called an "application", "form", "government form", or "request". We chose the name "application form" to avoid ambiguity with web development terms like _web_ application or _HTML_ form.

While most intake processes are application forms, there are some important exceptions that can also be implemented using the ApplicationForm class:

- **Appeals**: When someone wants to contest a decision, they submit an appeal. While we don't typically call it an "application form" in domain language, an appeal can be implemented as a subclass of ApplicationForm.
- **Reporting**: Some programs require periodic reporting for compliance. For example:
  - Businesses submitting wage reports for unemployment insurance programs
  - Medicaid beneficiaries submitting activity reports to maintain coverage.
  
  These reports can also be implemented as subclasses of ApplicationForm.

## Key Concepts

### `ApplicationForm` class

[ApplicationForm](./app/models/flex/application_form.rb) is an abstract parent class that should be used when creating new Flex forms within your application.

Out-of-the-box, [ApplicationForm](./app/models/flex/application_form.rb) provides a `status` attribute that comes with 2 options: "in_progress" or "submitted". The default option is "in_progress". Whenever a form is submitted, its status will change to "submitted". Any attempts to change any attributes on this form after the status is changed to "submitted" will result in error.

## Creating a new form

Creating a new Flex form follows a similar process to generating a standard Rails model, with the key difference being that the model extends from ApplicationForm instead of ApplicationRecord. This guide walks through the implementation of an example passport application processing system.

### 1. Generate an application form model

Run the following command to generate a new application form model. Replace the name of the application form with the desired name.

```shell
bin/rails generate flex:application_form PassportApplicationForm
```

If you already know some of the attributes you want to include in the form, you can specify them in the generate command, like so:

```shell
bin/rails generate flex:application_form PassportApplicationForm name:name birth_date:memorable_date ssn:tax_id residential_address:address
```

For a list of supported attributes, see [Flex Data Modeler](/docs/flex-data-modeler.md).

Alternatively, use the `bin/rails generate scaffold` command to generate additional files such as views:

```shell
bin/rails generate scaffold PassportApplicationForm
```

### 2. Update the model to extend from Flex::ApplicationForm

```ruby
# models/flex/passport_application_form.rb
class PassportApplicationForm < Flex::ApplicationForm # <-- ensure that you're extending from Flex::ApplicationForm, not ApplicationRecord
```

### 3. Add attributes to your model

Add attributes to your model. More can be added later.

```ruby
class PassportApplicationForm < Flex::ApplicationForm
  flex_attribute :name, :name
  flex_attribute :birth_date, :memorable_date
  flex_attribute :ssn, :tax_id
  flex_attribute :residential_address, :address
end
```

For more information about how to use Flex attributes, see [Flex Data Modeler](/docs/flex-data-modeler.md).

### 4. Generate migrations for added attributes

Generate a migration. The migration needs to include the following attributes in the `ApplicationForm` base class:

- `status:integer`
- `user_id:uuid`
- `submitted_at:datetime`

```shell
bin/rails generate flex:migration status:integer user_id:uuid submitted_at:datetime name:name birth_date:memorable_date ssn:tax_id residential_address:address
```

For more information about the Flex migration generator, see [Flex Data Modeler](/docs/flex-data-modeler.md).

### 4. Run migrations

```shell
bin/rails db:migrate
```

### 5. Test the form

Test the form by using it in the rails console.

```shell
bin/rails console
```

```ruby
form = PassportApplicationForm.new
form.name = "John Doe"
form.birth_date = { year: 1990, month: 1, day: 1 }
form.ssn = "123-45-6789"
form.residential_address = { street_address_line_1: "123 Main St", street_address_line_2: "Apt 4B", city: "Anytown", state: "CA", zip: "12345" }
form.save
```

> [!NOTE]  
> This documentation is a work in progress. It still needs documentation on how to generate and test views, controllers, and routes
> In the meantime, if you find any issues, please provide feedback or suggestions for improvement to the Flex SDK team.

## Next Steps

[Create a case management business process](./docs/case-management-business-process.md)
