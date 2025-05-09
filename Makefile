.PHONY: \
	lint \
	lint-ci \
	test \
	test-coverage \
	test-watch \
	typecheck \
	typecheck-setup \
	help

setup:
	bundle install

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

typecheck: ## Run type checking
	bundle exec steep check	

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
