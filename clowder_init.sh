#!/bin/sh

if [[ -z "${ACG_CONFIG}" ]]; then
  export PG_BOUNCER_LISTEN_PORT="5432"
else
  export DB_NAME="`cat $ACG_CONFIG | jq -r '.database.name // empty'`"
  export DB_HOST="`cat $ACG_CONFIG | jq -r '.database.hostname // empty'`"
  export DB_PORT="`cat $ACG_CONFIG | jq -r '.database.port // empty'`"
  export DB_USER="`cat $ACG_CONFIG | jq -r '.database.username // empty'`"
  export DB_PASSWORD="`cat $ACG_CONFIG | jq -r '.database.password // empty'`"
  export DB_SSLMODE="`cat $ACG_CONFIG | jq -r '.database.sslMode // empty'`"
  export DB_CAFILE="/etc/pgbouncer/rdsca.cert"
  export PG_BOUNCER_LISTEN_PORT="`cat $ACG_CONFIG | jq -r '.webPort'`"

  db_cert="`cat $ACG_CONFIG | jq -r '.database.rdsCa // empty'`"
  >${DB_CAFILE}
  if [[ -n "${db_cert}" ]]; then
    echo "${db_cert}" > ${DB_CAFILE}
    unset db_cert
  fi

  [[ -z "${DB_PORT}" ]] && DB_PORT="5432"
fi
