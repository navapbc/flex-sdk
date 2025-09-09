# Copilot Agent Instructions for Flex SDK

## Repository Overview

This repository contains the Flex SDK, a Ruby on Rails engine designed to help create intuitive, accessible, and effective digital-native government services. The SDK provides components for:

- Multi-page intake application forms
- Case management workflows
- Business process modeling
- Policy-as-code rules engine
- Data modeling with standardized government data fields

### Technical Stack

- **Primary Language**: Ruby
- **Framework**: Rails
- **Project Type**: Ruby Gem/Rails Engine
- **Key Dependencies**:
  - validates_timeliness
    - Version can be found in `flex.gemspec`
  - Rails
    - Version can be found in `flex.gemspec`

## Build and Test Instructions

### Environment Setup Prerequisites

- Docker
- NodeJS
- Ruby (version specified in `.ruby-version` file)
- Ruby version manager recommended (rbenv, mise, or frum)

### Initial Setup Commands

Always run these commands in this order when setting up:

```bash
make setup  # Installs dependencies, creates .env, and initializes database
```

### .env configuration

After running `make setup`, you or the user will need to configure environment variables in the `.env` file located at `./spec/dummy/.env`.

This file is used to set up the necessary environment for the dummy application.

### Database Setup

The database is automatically set up by `make setup`, but if needed separately:

1. Ensure `.env` exists at `./spec/dummy/.env`
2. Run `make init-db`

### Testing Commands

To run tests:

```bash
make test       # Run full test suite with coverage
make test-watch # Watch mode for development
```

### Common Issues and Solutions

- If tests fail immediately, ensure database is running: `make db-up`
- If database errors occur, try: `make init-db`
- If changes don't appear to take effect, ensure you've run `make setup` first

## Project Layout

### Key Directories

- `/app`: Core Flex engine application code
  - `/app/controllers/flex`: Controllers for tasks and staff
  - `/app/models/flex`: Data models
  - `/app/views/flex`: View templates
  - `/app/helpers/flex`: Helper methods
- `/config`: Flex engine configuration files
  - `/config/routes.rb`: Route definitions
  - `/config/initializers`: Rails initializers
- `/db/migrate`: Flex engine database migrations
- `/lib/flex`: Core Flex engine configuration code
- `/spec`: Test files
  - `/spec/dummy`: Test application that's used to test the Flex engine

### Important Files

- `README.md`: Project overview and documentation
- `Makefile`: Build and development commands
- `CONTRIBUTING.md`: Contribution guidelines
- `Gemfile`: Ruby dependencies
- `docs/*`: Documentation files

### Architecture Notes

- The project is structured as a Rails engine
- Uses modular components (Form Builder, Data Modeler, etc.)
- Follows Ruby on Rails conventions for code organization
- Tests are RSpec-based and require a running database

## Validation Steps

1. Before submitting changes:

   - Run `make lint` to check code style
   - Run `make test` to run the test suite
   - Ensure all migrations are reversible, if possible
   - Test changes in the dummy app: `make start`

2. Database-related changes:
   - Always run `make db-migrate` after adding migrations
   - Verify `make db-rollback` works for new migrations

These instructions should help you work efficiently with the codebase. Only perform additional exploration if these instructions are found to be incomplete or incorrect for your specific task.
