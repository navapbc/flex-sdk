# Implementation Guidelines

This document provides guidelines for implementing features in the Flex SDK. Following these guidelines will help ensure code quality, maintainability, and consistency.

## Code Simplicity

### Remove Unnecessary Code

Keep implementations as simple as possible. Remove any code that doesn't serve a clear purpose:

- Methods that aren't used
- Commented-out code
- Unnecessary helper functions that duplicate built-in Rails functionality

#### Example:

```ruby
# Not recommended - Unnecessary formatting method
def formatted_address
  parts = [street_line_1]
  parts << street_line_2 if street_line_2.present?
  parts << "#{city}, #{state} #{zip_code}"
  parts.compact.join("\n")
end

# Better - Omit methods that aren't essential to the model's core functionality
# Let the view handle formatting concerns
```

### Leverage Rails Conventions

Use built-in Rails features and patterns rather than creating custom implementations:

- Use `composed_of` for value objects
- Leverage ActiveRecord validation mechanisms
- Use Rails attribute types and type casting

#### Example:

```ruby
# Good - Using composed_of with minimal custom code
composed_of :address,
  class_name: "Flex::Address",
  mapping: [
    [ "address_street_line_1", "street_line_1" ],
    [ "address_street_line_2", "street_line_2" ],
    [ "address_city", "city" ],
    [ "address_state", "state" ],
    [ "address_zip_code", "zip_code" ]
  ]

# Not recommended - Custom getters/setters when Rails provides functionality
def address
  # Custom implementation that duplicates Rails functionality
end

def address=(value)
  # Custom implementation that duplicates Rails functionality
end
```

## Value Objects

Use value objects to represent complex data structures:

- Implement `Comparable` for easy comparison
- Keep value objects immutable
- Use composed_of to map value objects to database columns

### Example:

```ruby
module Flex
  class Address
    include Comparable
    
    attr_reader :street_line_1, :street_line_2, :city, :state, :zip_code
    
    def initialize(street_line_1, street_line_2, city, state, zip_code)
      @street_line_1 = street_line_1
      @street_line_2 = street_line_2
      @city = city
      @state = state
      @zip_code = zip_code
    end
    
    def <=>(other)
      [street_line_1, street_line_2, city, state, zip_code] <=> 
      [other.street_line_1, other.street_line_2, other.city, other.state, other.zip_code]
    end
  end
end
```
