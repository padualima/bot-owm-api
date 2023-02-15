DEFAULT: help

help: ## Show this help
	@echo -e "usage: make [target]\n\ntarget:"
	@grep -F -h "##" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | sed -e 's/: ##\s*/\t/' | expand -t 30 | pr -to2

build: ## Build image project, install dependences and create local database
build:
	docker-compose build
	docker-compose run --rm api bundle install
	docker-compose run --rm api bundle exec rails db:create db:migrate

up: ## Go up api service
up:
	docker-compose up

restore: ## Restore server
restore:
	docker-compose run --rm api bundle exec rails db:drop db:create db:migrate

run_tests: ## Run the test suite
run_tests:
	docker-compose run --rm api bundle exec rspec

ifndef VERBOSE
.SILENT:
endif
