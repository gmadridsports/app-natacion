#!/usr/bin/env /bin/bash

source ./supabase/.env.local

DEFAULT_GSA_KEY=$(echo ${GSA_KEY} | awk '{gsub(/\"/,"\\\"")}1' | awk '{gsub(/\\n/,"\\\\n")}1');
read -p "Enter the GSA KEY [${DEFAULT_GSA_KEY}]: " -r INPUT_GSA_KEY

DEFAULT_GSA_EMAIL=${GSA_EMAIL};
read -p "Enter the GSA Key's associated email [${DEFAULT_GSA_EMAIL}]: " -r INPUT_GSA_EMAIL

DEFAULT_CALENDAR_EVENTS_ID=${CALENDAR_EVENTS_ID};
read -p "Enter the calendar events ID [${DEFAULT_CALENDAR_EVENTS_ID}]: " -r INPUT_CALENDAR_EVENTS_ID

echo "GSA_KEY=\"${INPUT_GSA_KEY:-${DEFAULT_GSA_KEY}}\"" > ./supabase/.env.local
echo "CALENDAR_EVENTS_ID=\"${INPUT_CALENDAR_EVENTS_ID:-${DEFAULT_CALENDAR_EVENTS_ID}}\"" >> ./supabase/.env.local
echo "GSA_EMAIL=\"${INPUT_GSA_EMAIL:-${DEFAULT_GSA_EMAIL}}\"" >> ./supabase/.env.local
