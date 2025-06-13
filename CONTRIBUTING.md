# Contributing to Flex SDK

## 💻 Getting started with local development

Prerequisites:

- Ruby version matching [`.ruby-version`](/.ruby-version)
- [Node LTS](https://nodejs.org/en)
- (Optional but recommended): A Ruby version manager like [rbenv](https://github.com/rbenv/rbenv), [mise](https://mise.jdx.dev/getting-started.html), or [frum](https://github.com/TaKO8Ki/frum) (see [Comparison of ruby version managers](https://github.com/rbenv/rbenv/wiki/Comparison-of-version-managers))

### Setup

Run setup

```bash
make setup
```

### Testing

```bash
make test
```

or run tests in watch mode to automatically re-run tests on file changes:

```bash
make test-watch
```

## Writing Tests

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
