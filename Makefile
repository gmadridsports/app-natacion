.PHONY: backend-start setup-backend backend-stop frontend-start setup-frontend test-flutter-android test-flutter-ios test-flutter-local test-build-artifact test-artifacts-push test-artifacts-pull test-backend setup-pre-commit setup-env-test integration-scp list

current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
hostname := $(hostname -f)
second-arg := $(word 2, $(MAKECMDGOALS))
SUPABASE_ADMIN_TEST_TEST_PASSWORD=$(shell cat dev/tests/env/supabase-admin-test-test-password)
SUPABASE_ADMIN_LOCAL_TEST_PASSWORD=$(shell cat dev/tests/env/supabase-admin-local-test-password)

backend-start:
	@echo "Starting the app"
	supabase start

backend-start-edge-functions:
	@echo "Starting the edge functions locally"
	supabase --env-file ./supabase/.env.local functions serve

setup-backend: setup-env-test backend-start
	@./dev/setup_env_backend.sh
	@echo "Setupping supabase"
	supabase db reset
	pushd supabase/supabase-init && dart pub get && popd
	dart supabase/supabase-init/populate_buckets.dart
	SUPABASE_ADMIN_LOCAL_TEST_PASSWORD=$(SUPABASE_ADMIN_TEST_TEST_PASSWORD) dart supabase/supabase-init/init_test_framework.dart

backend-stop:
	@echo "Stopping the backend"
	supabase stop

frontend-start: backend-start
	@echo "Starting the app"
	flutter run lib/main.dart --dart-define="ENV=local"

setup-frontend:
	@echo "Setting up the app"
	flutter pub get

test-flutter-android:
	@echo "Running Android tests"
	@SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_TEST_TEST_PASSWORD) ./dev/tests/integration_android_run.sh

test-flutter-ios:
	@echo "Running iOS tests"
	@SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_TEST_TEST_PASSWORD) ./dev/tests/integration_ios_run.sh

test-flutter-local-ios: backend-start
	@echo "Running tests locally on device ${second-arg}"
	@patrol test --target integration_test/$(test_path)  --dart-define="MODE=test" --dart-define="ENV=local" --dart-define="SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_LOCAL_TEST_PASSWORD)" --verbose -d $(second-arg)

test-flutter-local-android: backend-start
	@echo "Running tests locally on device ${second-arg}"
	@patrol test --target integration_test/$(test_path)  --release --flavor releaseTest --dart-define="MODE=test" --dart-define="ENV=local" --dart-define="SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_LOCAL_TEST_PASSWORD)" --verbose -d $(second-arg)

test-build-artifact:
	@echo "Building artifact"
	@SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_TEST_TEST_PASSWORD) ./dev/tests/integration_ios_build.sh
	@SUPABASE_ADMIN_TEST_PASSWORD=$(SUPABASE_ADMIN_TEST_TEST_PASSWORD) ./dev/tests/integration_android_build.sh
	./dev/tests/integration_update_artifact_latest_build.sh

test-artifacts-push: test-build-artifact
	@echo "Syncing to the remote..."
	./dev/tests/test_remote_sync.sh push

test-artifacts-pull:
	@echo "Pulling from the remote..."
	./dev/tests/test_remote_sync.sh pull

test-backend: backend-start
	@echo "Running backend tests"
	supabase test db

setup-pre-commit: setup-env-test
	@echo "Setting up pre-commit helper..."
	@cp dev/pre-commit-template .git/hooks/pre-commit
	@echo "Done!"

setup-env-test:
	@./dev/tests/setup_env_test.sh

integration-scp:
	./dev/tests/integration_scp.sh

list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
