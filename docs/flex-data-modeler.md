# Flex Data Modeler

The Flex Data Modeler simplifies the process of defining data models for your application. It provides built-in support for common attribute types and ensures data interoperability by leveraging Flex data standards.

## Flex Attributes

Flex Attributes extend ActiveRecord with custom attribute types, providing a consistent interface for defining specialized attributes like memorable dates, names, addresses, tax IDs, and money amounts.

### Supported Attribute Types

- `address`: Includes columns for street_line_1, street_line_2, city, state, and zip_code.
- `date_range`: Includes columns for start and end dates.
- `memorable_date`: Includes a single date column.
- `money`: Includes a single integer column to store cents.
- `name`: Includes columns for first, middle, and last names.
- `tax_id`: Includes a single string column.
- `us_date`: Includes a single date column.
- `year_quarter`: Includes columns for year and quarter.

### Example Usage

To use Flex Attributes in a model:

```ruby
class MyModel < ApplicationRecord
  include Flex::Attributes

  flex_attribute :birth_date, :memorable_date
  flex_attribute :applicant_name, :name
  flex_attribute :salary, :money
end
```

This allows you to define attributes with specialized behavior and column mappings, simplifying the process of working with complex data types.

## Flex Migration Generator

The Flex SDK provides a Rails generator to automatically create database migrations with the correct column definitions for Flex attributes.

### Usage

```shell
bin/rails generate flex:migration AddAttributesToModel attribute_name:attribute_type
```

### Example

```shell
bin/rails generate flex:migration AddPersonalInfoToUsers name:name date_of_birth:memorable_date address:address
```

This generates a migration with the appropriate columns:

- `name_first`, `name_middle`, `name_last` (string columns for the name attribute)

- `date_of_birth` (date column for the memorable_date attribute)  

- `address_street_line_1`, `address_street_line_2`, `address_city`, `address_state`, `address_zip_code` (string columns for the address attribute)

For a complete list of supported attribute types and their column mappings, run:

```shell
bin/rails generate flex:migration --help
```

Learn more about how to use the Flex migration generator by running `rails generate flex:migration --help`.
