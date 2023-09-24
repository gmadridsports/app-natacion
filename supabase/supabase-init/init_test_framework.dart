import 'dart:async';
import 'dart:io';
import 'package:postgres/postgres.dart';

void main() async {
  print('Initializing the testing framework with the test admin user...');
  await initialize();
  print('Initialized.');

  exit(0);
}

Future<void> initialize() async {
  Map<String, String> envVars = Platform.environment;
  var connection = PostgreSQLConnection(
      envVars['SUPABASE_POSTGRES_URL'] ?? 'localhost', 54322, "postgres",
      username: 'postgres',
      password: envVars['SUPABASE_POSTGRES_PASSWORD'] ?? 'postgres');
  await connection.open();

  final password = envVars['SUPABASE_ADMIN_LOCAL_TEST_PASSWORD'] ?? 'test';
  await connection.execute('''insert into "auth"."users" ("instance_id",
  "id",
      "aud",
      "role",
      "email",
      "encrypted_password",
      "email_confirmed_at",
      "invited_at",
      "confirmation_token",
      "confirmation_sent_at",
      "recovery_token",
      "recovery_sent_at",
      "email_change_token_new",
      "email_change",
      "email_change_sent_at",
      "last_sign_in_at",
      "raw_app_meta_data",
      "raw_user_meta_data",
      "is_super_admin",
      "created_at",
      "updated_at",
      "phone",
      "phone_confirmed_at",
      "phone_change",
      "phone_change_token",
      "phone_change_sent_at",
      "email_change_token_current",
      "email_change_confirm_status",
      "banned_until",
      "reauthentication_token",
      "reauthentication_sent_at",
      "is_sso_user")
  values ('00000000-0000-0000-0000-000000000000',
      uuid_generate_v4(),
      'authenticated',
      'authenticated',
      'test+admin@gmadridnatacion.bertamini.net',
      crypt('${password}', gen_salt('bf')),
      now(),
      null,
      '',
      now(),
      '',
      null,
      '',
      '',
      null,
      now(),
      '{"provider": "email", "providers": ["email"]}',
      '{}',
      null,
      now(),
      now(),
      null,
      null,
      '',
      '',
      null,
      '',
      0,
      null,
      '',
      null,
      'f');
      ''');

  await connection.execute(''' 
  SET schema 'cron';
select cron.schedule(
               'daily-test-users-cleanup',
               '30 4 * * *',
               \$\$ select delete_old_test_accounts() \$\$);
  ''');
}
