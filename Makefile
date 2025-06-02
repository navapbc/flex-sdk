.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch

##################################################
# Constants
##################################################

DOCKER_CMD := docker
DOCKER_APPROACH := run
RAILS_RUN_CMD := bin/rails
DB_RAILS_CMD := cd spec/dummy && dotenv -f ../../.env $(RAILS_RUN_CMD)

##################################################
# Setup
##################################################

.env: local.env.example
	@([ -f .env ] && echo ".env file already exists, but local.env.example is newer (or you just switched branches), check for any updates" && touch .env) || cp local.env.example .env

setup:
	bundle install

##################################################
# Database
##################################################

init-db: ## Initialize the project database
init-db: .env db-up wait-on-db db-migrate db-test-prepare db-seed

db-up: ## Run just the database container
	$(DOCKER_CMD) compose $(DOCKER_COMPOSE_ARGS) up --remove-orphans --detach $(DB_NAME)

db-migrate: ## Run database migrations
	$(DB_RAILS_CMD) db:migrate

db-rollback: ## Rollback a database migration
	$(DB_RAILS_CMD) db:rollback

db-test-prepare: ## Prepare the test database
	$(DB_RAILS_CMD) db:test:prepare

db-seed: ## Seed the database
	$(DB_RAILS_CMD) db:seed

db-reset: ## Reset the database
	$(DB_RAILS_CMD) db:reset

db-console: ## Access the rails db console
	$(DB_RAILS_CMD) dbconsole

wait-on-db:
	dotenv ./bin/wait-for-local-postgres.sh

# db-reset: ## Reset the database
# 	cd spec/dummy && bundle exec rails db:reset

# db-migrate: ## Run the database migrations
# 	cd spec/dummy && bundle exec rails db:migrate

##################################################
# Linting
##################################################

lint: ## Run the linter with auto-fixing
	bundle exec rubocop -a

lint-ci: ## Run the linter, but don't fix anything
	bundle exec rubocop

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
