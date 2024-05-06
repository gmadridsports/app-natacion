drop policy notification_tokens_update_policy on public.notification_tokens;
create policy notification_tokens_update_policy on public.notification_tokens for update using (user_id = auth.uid() and
                                                                                                'member' in
                                                                                                (select membership_level
                                                                                                 from public.profiles
                                                                                                 where id = auth.uid()));

alter table "public"."profiles"
    add column "notification_preferences" jsonb default '{
      "other": true,
      "training-week": true,
      "bulletin-board": true
    }'::jsonb;


CREATE OR REPLACE FUNCTION default_user_notification_preferences()
    RETURNS jsonb
    LANGUAGE SQL AS
$$
SELECT notification_preferences
FROM profiles
WHERE id = auth.uid();
$$;
alter table "public"."notification_tokens"
    add column "preferences" jsonb default default_user_notification_preferences();

-- if profile notifications is updated, then update all the related notifications tokens
CREATE OR REPLACE FUNCTION update_notifications_preferences_for_user()
    RETURNS TRIGGER AS
$$
BEGIN
    UPDATE "public"."notification_tokens" SET preferences = NEW.notification_preferences WHERE user_id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_update_profile
    BEFORE INSERT OR UPDATE
    ON "public"."profiles"
    FOR EACH ROW
EXECUTE FUNCTION update_notifications_preferences_for_user();

-- add the new default values for the profiles which did not have the column
UPDATE "public"."profiles"
SET notification_preferences = '{
  "other": true,
  "training-week": true,
  "bulletin-board": true
}'
WHERE id = id;
UPDATE "public"."notification_tokens"
SET preferences = '{
  "other": true,
  "training-week": true,
  "bulletin-board": true
}'
WHERE user_id = user_id;

drop policy "authenticated users can ONLY READ their own profile"
    on "public"."profiles";

create policy "authenticated users can READ their own profile"
    on "public"."profiles"
    as permissive
    for select
    to authenticated
    using ((auth.uid() = id));

create policy "authenticated users can UPDATE their own profile"
    on "public"."profiles"
    as permissive
    for update
    to authenticated
    using ((auth.uid() = id));

-- only column notifications can be updated by the user
revoke
    update
    on table public.profiles
    from
    authenticated;

revoke
    insert
    on table public.profiles
    from
    authenticated;

grant
    update
    (notification_preferences) on table public.profiles to authenticated;

-- only member can edit their own notifications column, admins roles can do it
CREATE OR REPLACE FUNCTION check_member_only_edit_preferences() RETURNS TRIGGER AS
$$
BEGIN
    if (jsonb_pretty(new.notification_preferences) = jsonb_pretty(old.notification_preferences))
    then
        return new;
    end if;

    IF current_user IN ('postgres', 'service_role', 'supabase_auth_admin', 'supabase_admin', 'dashboard_user') THEN
        return new;
    END IF;

    IF (jsonb_pretty(new.notification_preferences) != jsonb_pretty(old.notification_preferences) and
        'member' not in (select membership_level from public.profiles where id = auth.uid()))
    THEN
        RAISE EXCEPTION 'You cannot change these values by yourself.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
create trigger t_check_user_profile
    before update or insert
    on "public"."profiles"
    for each row
execute procedure check_member_only_edit_preferences();

-- if a notification token is added/edited, the preferences from profiles are copied
CREATE OR REPLACE FUNCTION notifications_preferences_with_profiles_preferences()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.preferences = (SELECT notification_preferences
                       FROM profiles
                       WHERE id = (SELECT user_id from auth.sessions where id = NEW.session_id));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_update_profile
    BEFORE INSERT OR UPDATE
    ON "public"."notification_tokens"
    FOR EACH ROW
EXECUTE FUNCTION notifications_preferences_with_profiles_preferences();
