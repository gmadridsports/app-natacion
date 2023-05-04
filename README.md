# Gmadrid Natación App

GMadrid Natación

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup
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


