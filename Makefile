.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch

##################################################
# Constants
##################################################

RAILS_CMD := cd spec/dummy && bundle exec rails

##################################################
# Setup
##################################################

spec/dummy/.env: spec/dummy/local.env.example
	@([ -f spec/dummy/.env ] && echo "spec/dummy/.env file already exists, but spec/dummy/local.env.example is newer (or you just switched branches), \
	check for any updates" && touch spec/dummy/.env) || cp spec/dummy/local.env.example spec/dummy/.env

setup:
	npm install --prefix spec/dummy
	bundle install

##################################################
# Database
##################################################

init-db: ## Initialize the project database
init-db: db-up wait-on-db db-migrate db-test-prepare db-seed

db-up: ## Run just the database container
	docker compose -f spec/dummy/docker-compose.yml up --remove-orphans --detach $(DB_NAME)

db-migrate: ## Run database migrations
	$(RAILS_CMD) db:migrate

db-rollback: ## Rollback a database migration
	$(RAILS_CMD) db:rollback

db-test-prepare: ## Prepare the test database
	$(RAILS_CMD) db:test:prepare

db-seed: ## Seed the database
	$(RAILS_CMD) db:seed

db-reset: ## Reset the database
	$(RAILS_CMD) db:reset

db-console: ## Access the rails db console
	$(RAILS_CMD) dbconsole

wait-on-db:
	dotenv -f spec/dummy/.env ./spec/dummy/bin/wait-for-local-postgres.sh

##################################################
# Linting
##################################################

lint: ## Run the linter with auto-fixing
	bundle exec rubocop -a

lint-ci: ## Run the linter, but don't fix anything
	bundle exec rubocop

##################################################
# Testing
##################################################

test: ## Run the test suite and generate a coverage report
test: db-up
	bundle exec rspec

test-watch: ## Watch for file changes and run the test suite
	bundle exec guard

test-coverage: ## Open the test coverage report
	open coverage/index.html

##################################################
# Dummy App
##################################################

start: ## Start the dummy app server
start: db-up
	$(RAILS_CMD) server

##################################################
# Other
##################################################

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
