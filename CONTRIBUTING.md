# Contributing to Flex SDK

## 💻 Getting started with local development

Prerequisites:

- Ruby version matching [`.ruby-version`](/template/{{app_name}}/engines/flex/.ruby-version)
- [Node LTS](https://nodejs.org/en)
- (Optional but recommended): A Ruby version manager like [rbenv](https://github.com/rbenv/rbenv), [mise](https://mise.jdx.dev/getting-started.html), or [frum](https://github.com/TaKO8Ki/frum) (see [Comparison of ruby version managers](https://github.com/rbenv/rbenv/wiki/Comparison-of-version-managers))

## Setup

Perform all development in the `flex` engine folder:

```bash
cd template/{{app_name}}/engines/flex/
```

Then run setup

```bash
make setup
```

## Testing

```bash
make test
```

or run tests in watch mode to automatically re-run tests on file changes:

```bash
make test-watch
```
