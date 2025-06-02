# Factories

## Name Factory

The name factory creates `Flex::Name` objects with configurable first, middle, and last names.

```ruby
# Empty name
name = build(:name)

# Basic name with first and last name
name = build(:name, :base)

# Name with middle name
name = build(:name, :base, :with_middle)
```

Note that Flex::Name is a value object, not an ActiveRecord model, so you can only use the `build` strategy. The `create` is not available for this factory.

## Address Factory

The address factory creates address objects with standard US address fields.

```ruby
# Empty address
address = build(:address)

# Basic address with required fields
address = build(:address, :base)

# Address with secondary address line
address = build(:address, :base, :with_street_line_2)
```

Note that Flex::Address is a value object, not an ActiveRecord model, so you can only use the `build` strategy. The `create` is not available for this factory.
