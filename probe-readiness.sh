#!/bin/bash

# Note: host and port should remain localhost and ${PG_BOUNCER_LISTEN_PORT}
# because that represents the location of pgbouncer itself, not the
# remote psql server that would have $DB_HOST:$DB_PORT.

source /clowder_init.sh

PGPASSWORD="$DB_PASSWORD" /usr/pgsql-14/bin/psql \
  -h localhost -p ${PG_BOUNCER_LISTEN_PORT} -U "${DB_USER}" -d "${DB_NAME}" \
  -c "select 1 as psql_is_ready" 2>/dev/null \
  | grep "psql_is_ready"
exit $?

