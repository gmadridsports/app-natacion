# Gmadrid Natación App

GMadrid Natación. 
A Flutter application. Currently main focues on the iOS version.

## Setup
Needed:
- Apple developer program, or at least being part of the team
- XCode ~14.2
- Docker for supabase (backend support)
- A firebase account (testLab, push notifications and crash loggings)
- Apple certificates bound to the provisioning profiles (autosign is disabled)

### Supabase local
Install [supabase cli](https://supabase.com/docs/guides/cli)
```bash
brew install supabase/tap/supabase
```

[Start supabase](https://supabase.com/docs/guides/cli/local-development)
```bash
supabase login
supabase start
```

You can use the `supabase stop` command at any time to stop all services.


### Reset the environment
```bash
supabase db reset

# buckets
dart supabase/buckets-init/populate_buckets.dart
dart populate_buckets.dart
```

## Tests
Mainly focused on e-2-e tests. Tests are executed with `patrol` lib, in place of the `integration_tests` one, in order to have full control on the device (accepting notification dialogs etc.) when performing remotely.

## Workflow
- develop a feat branch, along with its tests and commit it
- By committing, an integration test release is generated and attacched to the commit automatically. If you don't want to generate it, you can skip it by using `git commit --no-verfify` flag
- When a PR is opened, both supabase and integration tests are performed via github actions. See the actions to discover how they're executed. In case `--no-verify` has been used, the build will be generated ‼️️in that case the test will take up to 30mins!