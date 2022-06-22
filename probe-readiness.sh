#!/bin/bash

function logtime() {
  echo "$(date --iso-8601=ns) $1" | tee -a $LOGPATH
}


PID="$$"
LOGPATH=/tmp/log-readiness-"$PID"

exec {BASH_XTRACEFD}>>$LOGPATH
#set -x

# Note: host and port should remain localhost and ${PG_BOUNCER_LISTEN_PORT}
# because that represents the location of pgbouncer itself, not the
# remote psql server that would have $DB_HOST:$DB_PORT.
source /clowder_init.sh

logtime "before psql select"
PGPASSWORD="$DB_PASSWORD" /usr/pgsql-14/bin/psql \
  -h localhost -p ${PG_BOUNCER_LISTEN_PORT} -U "${DB_USER}" -d "${DB_NAME}" \
  -c "select 1 as psql_is_ready" 2>/dev/null \
  | grep "psql_is_ready" | tee -a $LOGPATH
RESULT=$?

logtime "psql finished"
echo "result was $RESULT" | tee -a $LOGPATH
exit $RESULT

