import { GoogleAPI } from "https://deno.land/x/google_deno_integration/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";
import { stripHtml } from "https://esm.sh/string-strip-html@13.4.3";

Deno.serve(async (req) => {
  // todo check that the JWT is a valid member, not only user

  // todo reading the service account
  // const serviceAccountConfig = await Deno.readTextFile(Deno.env.get('GSA_KEY') ?? '');
  const serviceAccountConfig = Deno.env.get('GSA_KEY') ?? '';
  const credentials = JSON.parse(serviceAccountConfig);

  const cal_id =  Deno.env.get('CALENDAR_EVENTS_ID') ?? '';

  const api = new GoogleAPI({
    email: Deno.env.get('GSA_EMAIL') ?? '',
    scope: ["https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/calendar.events"],
    key: credentials.private_key,
  });

  const calget = await api.get(`https://www.googleapis.com/calendar/v3/calendars/${cal_id}/events`);

  for (const event of calget.items) {
    event.description = stripHtml(event.description).result;
  }

  return new Response(JSON.stringify(calget), { headers: { 'Content-Type': 'application/json' } })
})


