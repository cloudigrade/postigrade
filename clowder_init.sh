#!/bin/sh

logtime "start clowder_init..."
echo "start clowder_init.sh"  | tee -a $LOGPATH

if [[ -z "${ACG_CONFIG}" ]]; then
  logtime "export PG_BOUNCER_LISTEN_PORT..."
  export PG_BOUNCER_LISTEN_PORT="5432"
else
  logtime "export DB_NAME..."
  export DB_NAME="`cat $ACG_CONFIG | jq -r '.database.name // empty'`"
  logtime "export DB_HOST..."
  export DB_HOST="`cat $ACG_CONFIG | jq -r '.database.hostname // empty'`"
  logtime "export DB_PORT..."
  export DB_PORT="`cat $ACG_CONFIG | jq -r '.database.port // empty'`"
  logtime "export DB_USER..."
  export DB_USER="`cat $ACG_CONFIG | jq -r '.database.username // empty'`"
  logtime "export DB_PASSWORD..."
  export DB_PASSWORD="`cat $ACG_CONFIG | jq -r '.database.password // empty'`"
  logtime "export DB_SSLMODE..."
  export DB_SSLMODE="`cat $ACG_CONFIG | jq -r '.database.sslMode // empty'`"
  logtime "export DB_CAFILE..."
  export DB_CAFILE="/etc/pgbouncer/rdsca.cert"
  logtime "export PG_BOUNCER_LISTEN_PORT..."
  export PG_BOUNCER_LISTEN_PORT="`cat $ACG_CONFIG | jq -r '.webPort'`"

  logtime "db_cert=..."
  db_cert="`cat $ACG_CONFIG | jq -r '.database.rdsCa // empty'`"
  >${DB_CAFILE}
  if [[ -n "${db_cert}" ]]; then
    logtime "echo db_cert to DB_CAFILE..."
    echo "${db_cert}" > ${DB_CAFILE}
    logtime "unset db_cert..."
    unset db_cert
  fi

  [[ -z "${DB_PORT}" ]] && DB_PORT="5432"
fi

logtime "exit clowder_init..."
echo "exit clowder_init.sh" | tee -a $LOGPATH
