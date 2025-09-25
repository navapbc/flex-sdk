# Contributing new Flex attributes

This document describes how to create new Flex attributes

## Design

1. Decide whether or not to create a new value object in app/models/flex/
   By default, Flex attributes will require creating a new value object. The exception is if the type of the attribute is already a native Ruby type, such as the memorable_date attribute which represents a Date object.

2. Determine if the attribute is composed of multiple nested attributes:

   If YES (e.g., name with first/middle/last or address with street/city/state):
   - Implement using getter and setter methods
   - Define individual attributes for each component
   - Define a getter that constructs the value object from components
   - Define a setter that handles both value object and hash input

   Example:

   ```ruby
   # Define components
   attribute "#{name}_first", :string
   attribute "#{name}_last", :string
   
   # Getter returns value object
   define_method(name) do
     first = send("#{name}_first")
     last = send("#{name}_last")
     Strata::Name.new(first, last)
   end
   
   # Setter handles both types
   define_method("#{name}=") do |value|
     case value
     when Strata::Name
       send("#{name}_first=", value.first)
       send("#{name}_last=", value.last)
     when Hash
       send("#{name}_first=", value[:first])
       send("#{name}_last=", value[:last])
     end
   end
   ```

   If NO (e.g., tax_id or money):
   - Create a subclass of ActiveModel::Type::Value
   - Implement the cast method to handle conversion from various input types
   - Use attribute with the custom type

   Example:

   ```ruby
   class MoneyType < ActiveModel::Type::Integer
     def cast(value)
       case value
       when Strata::Money
         value
       when Hash
         Strata::Money.new(value[:cents])
       when Integer
         Strata::Money.new(value)
       end
     end
   end
   
   attribute name, MoneyType.new
   ```

3. Decide if there are validations that need to be added by default.
   Note: Do not add presence option or validation. By default all Flex attributes allow nil.

## Implementation

1. Create the value object
2. Create a Concern `{FlexAttributeType}Attribute` in `app/lib/strata/attributes/` with a class method `{flex_attribute_type}_attribute` that takes the attribute `name` and an `options` hash and defines the new flex_attribute type on the including class, then include the module in Strata::Attributes in `app/lib/strata/attributes.rb`
   1. **Important**: The `flex_attribute` method in `app/lib/strata/attributes.rb` dynamically calls `#{type}_attribute`, so following the naming convention for the class method is required for the attribute to work properly.
3. Extend the `flex:migration` generator in `migration_generator.rb` to include the new Flex attribute.
4. For testing, add the new flex attribute to TestRecord in `spec/dummy/app/models/test_record.rb`. Try using the flex migration generator to generate this migration by running `cd spec/dummy && bin/rails generate flex:migration Add<AttributeName>ToTestRecords <attribute_name>:<flex_attribute_type>` and then run the migration with `bin/rails db:migrate`
5. Add tests to spec/dummy/spec/lib/flex/attributes_spec.rb leveraging the new flex attribute. Make sure to test:
  a. Assign a Hash to the attribute and make sure the attribute is cast to the value object type and has the correct value
  b. Load the attribute from the database and make sure the attribute is correctly cast from the database record to the value object type and has the correct value
  c. Test validation logic if relevant. When testing validation logic, check that the appropriate error objects are present and that the original uncast values are present so that they can be shown to the user to be fixed.
1. Create the associated FormBuilder helper method for rendering the form fields associated with the Flex attribute. (See [Contributing FormBuilder helper methods](/docs/contributing/contributing-form-builder-helper-methods.md))

See the existing attribute tests in the codebase for examples.
