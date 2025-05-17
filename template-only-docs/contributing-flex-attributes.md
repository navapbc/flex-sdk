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
          
          # Set up composed_of for ActiveRecord models
        end
      end
    end
  end
end
```

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

See the existing attribute tests in the codebase for examples.
