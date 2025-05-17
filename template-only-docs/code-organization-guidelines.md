# Code Organization Guidelines

This document provides guidelines for organizing code in the Flex SDK. Following these guidelines will help maintain consistency and readability across the codebase.

## Alphabetical Ordering

### Attributes in Models and Classes

Always sort attributes alphabetically in models, classes, and other declarations.

#### Example:

```ruby
# Good
flex_attribute :address, :address
flex_attribute :date_of_birth, :memorable_date
flex_attribute :name, :name

# Not recommended
flex_attribute :name, :name
flex_attribute :address, :address
flex_attribute :date_of_birth, :memorable_date
```

### Attributes in the `flex_attribute` Registry

When adding a new attribute type to the `Flex::Attributes` module, ensure it's placed in alphabetical order with the other attribute types.

#### Example:

```ruby
# In app/lib/flex/attributes.rb
def flex_attribute(name, type, options = {})
  case type
  when :address
    address_attribute name, options
  when :memorable_date
    memorable_date_attribute name, options
  when :name
    name_attribute name, options
  else
    raise ArgumentError, "Unsupported attribute type: #{type}"
  end
end
```

## File and Directory Structure

Follow Rails conventions for file and directory structure. Place files in appropriate directories based on their purpose:

- Models in `app/models/flex/`
- Attribute definitions in `app/lib/flex/attributes/`
- Tests in corresponding spec directories

Maintain consistency in file naming conventions, using snake_case for file names and CamelCase for class names.
