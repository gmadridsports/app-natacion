import {GoogleAPI} from "https://deno.land/x/google_deno_integration/mod.ts";
import {createClient} from "https://esm.sh/@supabase/supabase-js";
import {stripHtml} from "https://esm.sh/string-strip-html@13.4.3";

Deno.serve(async (req) => {
    try {
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            {global: {headers: {Authorization: req.headers.get('Authorization')!}}}
        )
        const {data, error} = await supabase.from('profiles').select('membership_level');

        if (error) {
            throw error;
        }

        if (data[0]?.membership_level !== 'member') {
            return new Response(JSON.stringify({error: 'Unauthorized'}), {
                headers: {'Content-Type': 'application/json'},
                status: 403
            });
        }

        const serviceAccountKey = Deno.env.get('GSA_KEY') ?? '';
        const credentials = JSON.parse(serviceAccountKey);
        const calendarId = Deno.env.get('CALENDAR_EVENTS_ID') ?? '';

        const api = new GoogleAPI({
            email: Deno.env.get('GSA_EMAIL') ?? '',
            scope: ["https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/calendar.events"],
            key: credentials.private_key,
        });

        const {fromIncluded, toIncluded} = await req.json();
        const calendarResponse = await api.get(`https://www.googleapis.com/calendar/v3/calendars/${calendarId}/events?timeMin=${new Date(+fromIncluded).toISOString()}&timeMax=${new Date(+toIncluded).toISOString()}`);

        for (const event of calendarResponse.items) {
            event.description = stripHtml(event.description).result;
        }

        return new Response(JSON.stringify(calendarResponse), {headers: {'Content-Type': 'application/json'}})
    } catch (e) {
        return new Response(JSON.stringify({error: 'An unexpected error occurred. Is the body sent into an expected format?'}), {
            headers: {'Content-Type': 'application/json'},
            status: 500
        });
    }
})


