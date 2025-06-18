All business logic should be thoroughly tested. When writing tests, engineers should:

- Test multiple scenarios to ensure comprehensive coverage.
- Consider creating data-driven tests, where the same test might be looped over with different input data.
- Utilize tools like [Faker](https://github.com/faker-ruby/faker) to generate randomized data for testing.
- Cover all test and edge cases, including:
  - Handling `nil` inputs.
  - Inputs that exceed expected length or size.
  - Scenarios where errors are raised.
  - Etc.

By following these guidelines, tests will be more robust and will help ensure the reliability of our software.
