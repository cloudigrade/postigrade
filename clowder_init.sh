#!/bin/sh

if [[ -z "${ACG_CONFIG}" ]]; then
  export PG_BOUNCER_LISTEN_PORT="5432"
else
  export DB_NAME="`cat $ACG_CONFIG | jq -r '.database.name // empty'`"
  export DB_HOST="`cat $ACG_CONFIG | jq -r '.database.hostname // empty'`"
  export DB_PORT="`cat $ACG_CONFIG | jq -r '.database.port // empty'`"
  export DB_USER="`cat $ACG_CONFIG | jq -r '.database.username // empty'`"
  export DB_PASSWORD="`cat $ACG_CONFIG | jq -r '.database.password // empty'`"
  export PG_BOUNCER_LISTEN_PORT="`cat $ACG_CONFIG | jq -r '.webPort'`"

  [[ -z "${DB_PORT}" ]] && DB_PORT="5432"
fi
