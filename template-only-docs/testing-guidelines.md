# Testing Guidelines

This document provides guidelines for testing code in the Flex SDK. Following these guidelines will help ensure code quality, reliability, and maintainability.

## Test Organization

### Test File Structure

Organize tests to mirror the structure of the code being tested:

- Place attribute tests in `spec/dummy/spec/lib/flex/attributes_spec.rb`
- Place model tests in `spec/dummy/spec/models/`
- Group related tests using RSpec's `describe` and `context` blocks

### Test Context

Use descriptive contexts to clearly indicate what aspect of the code is being tested:

```ruby
# Good
describe "date_range attribute" do
  context "when start date is after end date" do
    # Tests for invalid date range
  end
  
  context "with only one date set to nil" do
    # Tests for partially nil date range
  end
end

# Not recommended
describe "date_range attribute" do
  it "should be invalid when start date is after end date" do
    # Test without clear context
  end
end
```

## Test Coverage

Ensure comprehensive test coverage for your code:

### Happy Path Testing

Test the expected behavior when code is used correctly:

```ruby
it "allows setting a Range of Date objects" do
  object.test_range = Date.new(2020, 1, 2)..Date.new(2020, 2, 3)
  expect(object.test_range_start).to eq(Date.new(2020, 1, 2))
  expect(object.test_range_end).to eq(Date.new(2020, 2, 3))
  expect(object.test_range).to eq(Date.new(2020, 1, 2)..Date.new(2020, 2, 3))
end
```

### Edge Case Testing

Test boundary conditions and error cases:

```ruby
context "when start date is after end date" do
  before do
    object.test_range_start = Date.new(2020, 2, 3)
    object.test_range_end = Date.new(2020, 1, 2)
  end

  it "is invalid with appropriate error message" do
    expect(object).not_to be_valid
    expect(object.errors[:test_range].first).to eq("Start date must be less than or equal to end date")
  end
end
```

## Localization in Tests

Ensure that error messages and other user-facing text use proper I18n translations:

1. Add appropriate translation keys to `config/locales/flex/en.yml`
2. Test that error messages display correctly in different locales
3. Use translation keys rather than hardcoded strings in validation error messages

```ruby
# In config/locales/flex/en.yml
en:
  flex:
    errors:
      date_range:
        invalid_range: "Start date must be less than or equal to end date"
        missing_date: "Both start and end dates must be present or both must be nil"
```
