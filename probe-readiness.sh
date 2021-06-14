#!/bin/bash

# Note: host and port should remain localhost and 5432 because
# those represent the location of pgbouncer itself, not the
# remote psql server that would have $DB_HOST:$DB_PORT.

PGPASSWORD="$DB_PASSWORD" /usr/pgsql-13/bin/psql \
  -h localhost -p 5432 -U "${DB_USER}" -d "${DB_NAME}" \
  -c "select 1 as psql_is_ready" 2>/dev/null \
  | grep "psql_is_ready"
exit $?

