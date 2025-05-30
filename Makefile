.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch

##################################################
# Constants
##################################################

include .env

# APP_NAME := flex-dummy-database

# Support other container tools like `finch`
ifdef CONTAINER_CMD
	DOCKER_CMD := $(CONTAINER_CMD)
else
	DOCKER_CMD := docker
endif

# Support executing commands in an existing container
DOCKER_APPROACH := run

# By default, all rails commands will run inside of the docker container
# if you wish to run this natively, add RAILS_RUN_APPROACH=local to your environment vars
# You can set this by either running `export RAILS_RUN_APPROACH=local` in your shell or add
# it to your ~/.zshrc file (and run `source ~/.zshrc`)
# ifeq "$(RAILS_RUN_APPROACH)" "local"
RAILS_RUN_CMD := bin/rails
# else
# RAILS_RUN_CMD := $(DOCKER_CMD) compose $(DOCKER_COMPOSE_ARGS) $(DOCKER_APPROACH) $(DOCKER_RUN_ARGS) --rm $(APP_NAME) bin/rails
# endif

# ifeq "$(RAILS_RUN_APPROACH)" "local"
# RUBY_RUN_CMD :=
# else
# RUBY_RUN_CMD := $(DOCKER_CMD) compose $(DOCKER_COMPOSE_ARGS) $(DOCKER_APPROACH) $(DOCKER_RUN_ARGS) --rm $(APP_NAME)
# endif

# Docker user configuration
# This logic is to avoid issues with permissions and mounting local volumes,
# which should be owned by the same UID for Linux distros. Mac OS can use root,
# but it is best practice to run things as with least permission where possible

# Can be set by adding user=<username> and/ or uid=<id> after the make command
# If variables are not set explicitly: try looking up values from current
# environment, otherwise fixed defaults.
# uid= defaults to 0 if user= set (which makes sense if user=root, otherwise you
# probably want to set uid as well).
ifeq ($(user),)
RUN_USER ?= $(or $(strip $(USER)),nodummy)
RUN_UID ?= $(or $(strip $(shell id -u)),4000)
else
RUN_USER = $(user)
RUN_UID = $(or $(strip $(uid)),0)
endif

export RUN_USER
export RUN_UID

##################################################
# Setup
##################################################

.env: local.env.example
	@([ -f .env ] && echo ".env file already exists, but local.env.example is newer (or you just switched branches), check for any updates" && touch .env) || cp local.env.example .env

init-db: ## Initialize the project database
init-db: .env db-up wait-on-db db-migrate db-test-prepare db-seed

setup:
	npm install --prefix spec/dummy
	bundle install

##################################################
# Database
##################################################

DB_RAILS_CMD = cd spec/dummy && DB_HOST=${DB_HOST} DB_USER=${DB_USER} DB_PASSWORD=${DB_PASSWORD} DB_PORT=${DB_PORT} DB_NAME=${DB_NAME} $(RAILS_RUN_CMD)

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

start:
	cd spec/dummy && bundle exec rails server

# db-reset: ## Reset the database
# 	cd spec/dummy && bundle exec rails db:reset

# db-migrate: ## Run the database migrations
# 	cd spec/dummy && bundle exec rails db:migrate

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
