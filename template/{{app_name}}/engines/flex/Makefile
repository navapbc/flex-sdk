.PHONY: \
	lint \
	lint-ci

lint: ## Run the linter with auto-fixing
	rubocop -a

lint-ci: ## Run the linter, but don't fix anything
	rubocop

help: ## Prints the help documentation and info about each command
	@grep -Eh '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
