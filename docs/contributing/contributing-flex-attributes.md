# Contributing new Flex attributes

This document describes how to create new Flex attributes

## Design

1. Decide whether or not to create a new value object in app/models/flex/
   By default, Flex attributes will require creating a new value object. The exception is if the type of the attribute is already a native Ruby type, such as the memorable_date attribute which represents a Date object.
2. Decide whether or not to implement the attribute using the `composed_of` method in Rails Active Record Aggregations (see [Active Record Aggregations](https://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html) for reference).
   Use composed_of if the value object is composed of multiple attributes that map directly to database columns. Examples include name (which includes first, middle, and last) and address (which includes street, city, state, zip_code) attributes. Do not use composed_of if the value object is a single attribute. Also do not use composed_of if any of the attributes that the object is composed of does not map directly to a database column, such as if the attribute is a virtual attribute defined by composed_of. In this case, implement the attribute by manually defining an attribute getter and setter in the model.
3. Decide whether or not to create a new subclass of ActiveRecord::Type::Value
   Subclasses of ActiveRecord::Type::Value are used to define how to cast values from other types to the value object type. When using composed_of, implement casting behavior using the constructor and converter options for composed_of. Do not create a subclass of ActiveRecord::Type::Value. When not using composed_of, create a subclass of ActiveRecord::Type::Value and define cast to accept a Hash object and return an instance of the value object. The specific class to subclass depends on your value type. For example for memorable_date we created a subclass of ActiveRecord::Type::Date, and for tax_id we created a subclass of ActiveRecord::Type::String.
4. Decide if there are validations that need to be added by default.
   Note:Do not add presence option or validation. By default all Flex attributes allow nil.

## Implementation

1. Create the value object
2. Create a module in app/lib/flex/attributes/ defining the new flex_attribute type and include the module in Flex::Attributes in app/lib/flex/attributes.rb
3. Extend the `flex:migration` generator in `migration_generator.rb` to include the new Flex attribute.
4. For testing, add the new flex attribute to TestRecord in `spec/dummy/app/models/test_record.rb`. Try using the flex migration generator to generate this migration by running `cd spec/dummy && bin/rails generate flex:migration Add<AttributeName>ToTestRecords <attribute_name>:<flex_attribute_type>` and then run the migration with `bin/rails db:migrate`
5. Add tests to spec/dummy/spec/lib/flex/attributes_spec.rb leveraging the new flex attribute. Make sure to test:
  a. Assign a Hash to the attribute and make sure the attribute is cast to the value object type and has the correct value
  b. Load the attribute from the database and make sure the attribute is correctly cast from the database record to the value object type and has the correct value
  c. Test validation logic if relevant. When testing validation logic, check that the appropriate error objects are present and that the original uncast values are present so that they can be shown to the user to be fixed.
1. Create the associated FormBuilder helper method for rendering the form fields associated with the Flex attribute. (See [Contributing FormBuilder helper methods](/docs/contributing/contributing-form-builder-helper-methods.md))

See the existing attribute tests in the codebase for examples.
