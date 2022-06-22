#!/bin/bash

PID="$$"
LOGPATH=/tmp/log-liveness-"$PID"

function logtime() {
  echo "$(date --iso-8601=ns) $1" | tee -a $LOGPATH
}


exec {BASH_XTRACEFD}>>$LOGPATH
#set -x


logtime "before clowder init"
source /clowder_init.sh

logtime "before pg_isready"
/usr/pgsql-14/bin/pg_isready -h localhost -p ${PG_BOUNCER_LISTEN_PORT} -U "${DB_USER}" | grep "accepting connections"  | tee -a $LOGPATH
RESULT=$?
logtime "after pg_isready"
echo "result was $RESULT" | tee -a $LOGPATH
exit $RESULT

