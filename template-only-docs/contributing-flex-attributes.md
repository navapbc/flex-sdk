# Contributing Flex Attributes

This document provides guidance for contributing new attribute types to the Flex SDK. Following these guidelines will help ensure that new attributes are implemented consistently and maintain the quality of the codebase.

## Attribute Implementation Pattern

When adding a new attribute type to the Flex SDK, follow this pattern:

1. Create a new module in `app/lib/flex/attributes/` (e.g., `address_attribute.rb`)
2. Create a value object class if needed in `app/models/flex/` (e.g., `address.rb`)
3. Include the attribute module in `Flex::Attributes`
4. Add the attribute type to the `flex_attribute` method in `app/lib/flex/attributes.rb`
5. Add tests in `spec/dummy/spec/lib/flex/attributes_spec.rb`

### Module Structure

```ruby
module Flex
  module Attributes
    module NewAttributeType
      extend ActiveSupport::Concern
      
      class_methods do
        def new_attribute_type_attribute(name, options = {})
          # Define base attributes
          
          # Set up validations if needed
          
          # Set up composed_of for ActiveRecord models if needed
        end
      end
    end
  end
end
```

### When to Use composed_of vs ActiveModel::Type::Value

When implementing a new attribute type, choose between using `composed_of` or creating a custom `ActiveModel::Type::Value` based on how the attribute maps to the database:

- Use `composed_of` when the value object represents data stored across multiple database columns. For example, an address attribute might map to street, city, state, and zip columns.
- Use a custom `ActiveModel::Type::Value` when the attribute data is stored in a single database column.

### Value Object Structure

If your attribute needs a value object:

```ruby
module Flex
  class NewValueObject
    include Comparable
    
    attr_reader :property1, :property2
    
    def initialize(property1, property2)
      @property1 = property1
      @property2 = property2
    end
    
    def <=>(other)
      [property1, property2] <=> [other.property1, other.property2]
    end
  end
end
```

### Integration with Flex::Attributes

Update the `flex_attribute` method in `app/lib/flex/attributes.rb`:

```ruby
def flex_attribute(name, type, options = {})
  case type
  when :address
    address_attribute name, options
  # Add your new attribute type in alphabetical order
  when :new_attribute_type
    new_attribute_type_attribute name, options
  when :memorable_date
    memorable_date_attribute name, options
  when :name
    name_attribute name, options
  else
    raise ArgumentError, "Unsupported attribute type: #{type}"
  end
end
```

## Testing New Attributes

Create comprehensive tests for your new attribute type:

1. Test basic functionality (setting/getting values)
2. Test edge cases and error conditions
3. Test validation error messages
4. Test integration with ActiveRecord models
5. For attributes using `composed_of`, test that setting the main attribute properly sets all the mapped database columns. For example, if you have an `address` attribute that is composed of `street`, `city`, `state`, and `zip` columns, verify that setting the `address` also sets all these individual columns correctly.

Example for testing a composed attribute:

```ruby
describe "Address attribute" do
  it "sets mapped columns when setting the address" do
    address = Flex::Address.new(
      street: "123 Main St",
      city: "Springfield",
      state: "IL",
      zip: "62701"
    )
    model.address = address
    expect(model.address).to eq(address)
    expect(model.address_street).to eq("123 Main St")
    expect(model.address_city).to eq("Springfield")
    expect(model.address_state).to eq("IL")
    expect(model.address_zip).to eq("62701")
  end
end
```

See the existing attribute tests in the codebase for examples.
