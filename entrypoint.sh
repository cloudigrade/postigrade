#!/bin/sh

PID="$$"
LOGPATH=/tmp/log-entrypoint-"$PID"

function logtime() {
  echo "$(date --iso-8601=ns)" | tee -a $LOGPATH
}

logtime
source /clowder_init.sh
logtime

set -e

function check_svc_status() {
  local SVC_NAME=$1 SVC_PORT=$2

  [[ $# -lt 2 ]] && echo "Error: Usage: check_svc_status svc_name svc_port" | tee -a $LOGPATH && exit 1

  while true; do
    logtime
    echo "${LOGPREFIX} Checking ${SVC_NAME}:$SVC_PORT status ..." | tee -a $LOGPATH
    ncat ${SVC_NAME} ${SVC_PORT} < /dev/null && break
    logtime
    echo "not ready yet" | tee -a $LOGPATH
    sleep 1
  done
  logtime
  echo "${LOGPREFIX} ${SVC_NAME}:${SVC_PORT} - accepting connections"
}


if [[ -n "${ACG_CONFIG}" ]]; then
  export LOGPREFIX="Clowder Init:"
  echo "${LOGPREFIX} Running in a clowder environment" | tee -a $LOGPATH

  echo "${LOGPREFIX} Database name:     ${DB_NAME}" | tee -a $LOGPATH
  echo "${LOGPREFIX} Database host:     ${DB_HOST}" | tee -a $LOGPATH
  echo "${LOGPREFIX} Database port:     ${DB_PORT}" | tee -a $LOGPATH
  echo "${LOGPREFIX} PG Bouncer port:   ${PG_BOUNCER_LISTEN_PORT}" | tee -a $LOGPATH
  if [[ -n "${DB_SSLMODE}" ]]; then
    echo "${LOGPREFIX} Database SSL Mode: ${DB_SSLMODE}" | tee -a $LOGPATH
  fi
  if [[ -s "${DB_CAFILE}" ]]; then
    echo "${LOGPREFIX} Database CA File:  ${DB_CAFILE}" | tee -a $LOGPATH
  fi

  [[ -z "${DB_HOST}" ]] && echo "${LOGPREFIX} Error: Missing Database configuration"  | tee -a $LOGPATH && exit 1

  # Wait for the database to be ready
  echo "${LOGPREFIX} Waiting for database readiness ..." | tee -a $LOGPATH
  check_svc_status $DB_HOST $DB_PORT
fi

PG_CONFIG_DIR=/etc/pgbouncer

logtime
# md5 and write the password
pass="md5$(echo -n "$DB_PASSWORD$DB_USER" | md5sum | cut -f 1 -d ' ')"
echo "\"$DB_USER\" \"$pass\"" >> ${PG_CONFIG_DIR}/userlist.txt
logtime
echo "Wrote authentication credentials to ${PG_CONFIG_DIR}/userlist.txt" | tee -a $LOGPATH

# pgbouncer config
printf "\
[databases]
${DB_NAME} = host=${DB_HOST} port=${DB_PORT:-5432} dbname=${DB_NAME} user=${DB_USER}

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = ${PG_BOUNCER_LISTEN_PORT}
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
admin_users = postgres
;; The following parameter allows access via newer JDBC driver
ignore_startup_parameters = extra_float_digits
;; SSL parameters for connecting to the postgres database
" > ${PG_CONFIG_DIR}/pgbouncer.ini

if [[ -n "${DB_SSLMODE}" ]]; then
  echo "server_tls_sslmode=${DB_SSLMODE}" >> ${PG_CONFIG_DIR}/pgbouncer.ini
fi

if [[ -s "${DB_CAFILE}" ]]; then
  echo "server_tls_ca_file=${DB_CAFILE}" >> ${PG_CONFIG_DIR}/pgbouncer.ini
fi

logtime
echo "Wrote pgbouncer config to ${PG_CONFIG_DIR}/pgbouncer.ini" | tee -a $LOGPATH

echo "Starting $*..." | tee -a $LOGPATH
exec "$@"
