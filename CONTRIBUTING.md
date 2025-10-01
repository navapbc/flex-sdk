# Contributing to Strata SDK

## 💻 Getting started with local development

### Prerequisites:

- [Docker](https://www.docker.com/)
- [NodeJS](https://nodejs.org)
- Ruby version matching [`.ruby-version`](./.ruby-version)
- (Optional but recommended): A Ruby version manager like [rbenv](https://github.com/rbenv/rbenv), [mise](https://mise.jdx.dev/getting-started.html), or [frum](https://github.com/TaKO8Ki/frum) (see [Comparison of ruby version managers](https://github.com/rbenv/rbenv/wiki/Comparison-of-version-managers))

### Setup

Run setup. This will:

1. Install dependencies
2. Create a `.env` file in the dummy app (`./spec/dummy/.env`) based on the template at `./spec/dummy/local.env.example`
3. Create the database for working locally with Strata

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

#### Debugging Tests

For instructions on how to debug tests, please see [debugging.md](./contributing/debugging.md).

## Writing Tests

Please see [our testing contribution guide](/docs/contributing/testing.md).

## Regenerate the local database

_Note: The database is already generated for you after running `make setup`, however if you'd like to generate it separately follow the below instructions._

1. Make sure a `.env` file exists at `./spec/dummy/.env`. If it doesn't, run `make spec/dummy/.env`.
2. Run `make init-db` to setup the database container for local development.
