#!/bin/bash

PGPASSWORD="$DB_PASSWORD" /usr/pgsql-13/bin/psql -h localhost -p 5432 -U postgres -c "select 1 as psql_is_ready" 2>/dev/null | grep "psql_is_ready"
exit $?

