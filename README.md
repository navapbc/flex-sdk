# Flex

Short description and motivation.

## Usage

### Forms

#### ApplicationForm

[ApplicationForm](./app/models/flex/application_form.rb) is an abstract parent class that should be used when creating new Flex forms within your application.

Out-of-the-box, [ApplicationForm](./app/models/flex/application_form.rb) provides a `status` attribute that comes with 2 options: "in_progress" or "submitted". The default option is "in_progress". Whenever a form is submitted, its status will change to "submitted". Any attempts to change any attributes on this form after the status is changed to "submitted" will result in error.

#### Creating a new form

Creating a new Flex form using ApplicationForm is relatively simple and can be completed similar to how a model is typically generated in rails, except that you will change your new model to extend from ApplicationForm.

#### Example using the Rails CLI

Let's pretend that I'm creating a new form to process passport applications.

##### Step 1: Run the Rails CLI

```shell
bin/rails generate model PassportApplicationForm first_name:string last_name:string date_of_birth:date # Add whatever other attributes you'd like
```

_**Alternatively**, you can choose to use the `bin/rails generate scaffold` command to generate additional files, such as views, to use with your form._

##### Step 2: Change your model to extend from ApplicationForm

```ruby
# models/flex/passport_application_form.rb
class PassportApplicationForm < ApplicationForm # <-- ensure that you're extending from ApplicationForm, not ApplicationRecord
  # Attributes and methods here
end
```

##### Step 3: Double-Check your migration

Since ApplicationForm is an abstract class it does not generate any tables or migrations on its own. The migration will be implemented by any children that implement ApplicationForm.

An example migration, based on the PassportApplicationForm example from above:

```ruby
# db/migrate/migration_file_name_here.rb
class CreateFlexPassportApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_passport_application_forms do |t|
      t.string :first_name
      t.string :last_namen
      t.date :date_of_birth
      t.integer :status, default: 0 # This ensures that the status column, which is present on ApplicationForm, gets created and defaults to "in_progress"

      t.timestamps # if you want your table and model to have auto-generated created_at and updated_at fields, add this
    end
  end
end
```

##### Step 4: Start using your form

At this point you should be able to use your newly created model to implement a form. If you used the `scaffold` command, you will likely need to update references, views, etc. that were auto-generated with the scaffold command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "flex", path: "engines/flex"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install flex
```

### Prerequisites

#### PostgreSQL

PostgreSQL is required for local development. We recommend installing PostgreSQL 14 using Homebrew:

```bash
# Install PostgreSQL 14
brew install postgresql@14

# Start PostgreSQL service (will also start on computer startup)
brew services start postgresql@14
```

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
