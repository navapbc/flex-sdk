.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch

##################################################
# Constants
##################################################

BUNDLE_EXEC_CMD := dotenv bundle exec
RAILS_CMD := cd spec/dummy && dotenv -f ../../.env bundle exec rails

##################################################
# Setup
##################################################

.env: local.env.example
	@([ -f .env ] && echo ".env file already exists, but local.env.example is newer (or you just switched branches), check for any updates" && touch .env) || cp local.env.example .env

setup:
	npm install --prefix spec/dummy
	bundle install
	make .env
	make init-db

##################################################
# Database
##################################################

init-db: ## Initialize the project database
init-db: .env db-up wait-on-db db-migrate db-test-prepare db-seed

db-up: ## Run just the database container
	docker compose up --remove-orphans --detach $(DB_NAME)

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
	dotenv ./bin/wait-for-local-postgres.sh

##################################################
# Linting
##################################################

lint: ## Run the linter with auto-fixing
	$(BUNDLE_EXEC_CMD) rubocop -a

lint-ci: ## Run the linter, but don't fix anything
	$(BUNDLE_EXEC_CMD) rubocop

##################################################
# Testing
##################################################

test: ## Run the test suite and generate a coverage report
	$(BUNDLE_EXEC_CMD) rspec

test-watch: ## Watch for file changes and run the test suite
	$(BUNDLE_EXEC_CMD) guard

test-coverage: ## Open the test coverage report
	dotenv open coverage/index.html

##################################################
# Dummy App
##################################################

start: ## Start the dummy app server
	$(RAILS_CMD) server

##################################################
# Other
##################################################

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
