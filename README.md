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
    create_table :flex_passport_application_forms, id: :uuid do |t|
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

### Generators

Generators provide you with extra functionality to generate files from the command line. This aims to speed up development by generating files for you.

#### Flex Model Generator

Flex provides a custom model generator that supports special attribute types like names, addresses, money values, and dates. The generator automatically includes `Flex::Attributes` and creates the appropriate database migrations with the correct column structure for each Flex attribute type.

#### Using the Generator

To generate a new model with Flex attributes, use the following command:

```shell
bin/rails generate flex:model NAME [attribute:type attribute:type] [options]
```

##### Options

- parent: Allows you to specify the parent class of the model. If not supplied, the parent class will default to `ApplicationRecord`.
  - Example: `bin/rails generate flex:model MedicaidUser name:name --parent User`

#### Examples

```shell
bin/rails generate flex:model Dog name:name owner:name rabies_id:integer --parent Wolf
bin/rails generate flex:model Person name:name address:address salary:money
bin/rails generate flex:model User email:string profile:name birth_date:memorable_date
```

#### Supported Flex Attribute Types

- `name` - Creates columns: name_first, name_middle, name_last (all :string)
- `address` - Creates columns: address_street_line_1, address_street_line_2, address_city, address_state, address_zip_code (all :string)
- `money` - Creates column: money (:integer)
- `memorable_date` - Creates column: memorable_date (:date)
- `us_date` - Creates column: us_date (:date)
- `tax_id` - Creates column: tax_id (:string)
- `year_quarter` - Creates columns: year_quarter_year (:integer), year_quarter_quarter (:integer)

The generator will create:

- A Rails model file that includes `Flex::Attributes` with the appropriate flex_attribute declarations
- A migration file with the correct database columns for each Flex attribute type

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

## Working locally in the flex-sdk repository

### Prerequisites

- [Docker](https://www.docker.com/)
- [NodeJS](https://nodejs.org)
- Ruby version matching [`.ruby-version`](./.ruby-version)

### Run Setup

Run `make setup`, which wil:

1. Install dependencies
2. Create a `.env` file in the dummy app (`./spec/dummy/.env`) based on the template at `./spec/dummy/local.env.example`
3. Create the database for working locally with Flex

### Generate the local database

_Note: The database is already generated for you after running `make setup`, however if you'd like to generate it separately follow the below instructions._

1. Make sure a `.env` file exists at `./spec/dummy/.env`. If it doesn't, run `make spec/dummy/.env`.
2. Run `make init-db` to setup the database container for local development.

## Documentation

- [Flex Attributes](./app/lib/flex/attributes.md) - Documentation for custom attribute types

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
