.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch

setup: db-setup
	npm install --prefix spec/dummy
	bundle install
	cd spec/dummy && bundle exec rails db:migrate

start:
	cd spec/dummy && bundle exec rails server

db-setup: ## Set up PostgreSQL databases and roles
	@echo "Setting up PostgreSQL..."
	@command -v psql >/dev/null 2>&1 || { echo "Error: PostgreSQL not installed. Please install PostgreSQL first."; exit 1; }
	@pg_isready >/dev/null 2>&1 || { echo "Error: PostgreSQL is not running. Please start PostgreSQL service."; exit 1; }
	@psql -c "SELECT 1" >/dev/null 2>&1 || { echo "Creating postgres role..."; createuser -s postgres 2>/dev/null || echo "Using current user for database"; }
	@createdb flex_sdk_dummy_development 2>/dev/null || echo "Development database already exists"
	@createdb flex_sdk_dummy_test 2>/dev/null || echo "Test database already exists"

db-reset: ## Reset the database
	cd spec/dummy && bundle exec rails db:reset

db-migrate: ## Run the database migrations
	cd spec/dummy && bundle exec rails db:migrate

lint: ## Run the linter with auto-fixing
	bundle exec rubocop -a

lint-ci: ## Run the linter, but don't fix anything
	bundle exec rubocop

test: ## Run the test suite and generate a coverage report
	bundle exec rspec

test-watch: ## Watch for file changes and run the test suite
	bundle exec guard

test-coverage: ## Open the test coverage report
	open coverage/index.html

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
