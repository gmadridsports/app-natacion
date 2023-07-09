.PHONY: backend-start backend-setup backend-stop frontend-start test-flutter-android test-flutter-ios test-local test-backend setup-pre-commit list frontend-setup

current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
hostname := $(hostname -f)

backend-start:
	@echo "Starting the app"
	supabase start

backend-setup: backend-start
	@echo "Setupping supabase"
	supabase db reset
	pushd supabase/buckets-init && dart pub get && popd
	dart supabase/buckets-init/populate_buckets.dart

backend-stop:
	@echo "Stopping the backend"
	supabase stop

frontend-start: backend-start
	@echo "Starting the app"
	flutter run lib/main.dart --dart-define="ENV=local"

frontend-setup:
	@echo "Setting up the app"
	flutter pub get

test-flutter-android:
	@echo "Running Android tests"
	./dev/tests/integration_android_run.sh

test-flutter-ios:
	@echo "Running iOS tests"
	./dev/tests/integration_ios_run.sh

test-local: backend-start
	@echo "Running tests locally"
	patrol test --target integration_test/main_test.dart --dart-define="SUPABASE_ADDRESS_PORT=http://$(hostname):54321" --verbose

test-backend: backend-start
	@echo "Running backend tests"
	supabase test db

setup-pre-commit:
	@echo "Setting up pre-commit helper..."
	@cp dev/pre-commit-template .git/hooks/pre-commit
	@ echo "Done!"

list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
