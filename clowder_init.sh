#!/usr/bin/env bash

env_file="/tmp/clowder_envs.sh"

if [[ -z "${ACG_CONFIG}" ]]; then
  export PG_BOUNCER_LISTEN_PORT="5432"
elif [[ ! -f "${env_file}" ]]; then
  python3 /json_to_env.py --prefix "CLOWDER_" "${ACG_CONFIG}" > "${env_file}"
fi

if [[ -f "${env_file}" && -n "${ACG_CONFIG}" ]]; then
  source "${env_file}"

  export DB_NAME="${CLOWDER_DATABASE_NAME}"
  export DB_HOST="${CLOWDER_DATABASE_HOSTNAME}"
  export DB_PORT="${CLOWDER_DATABASE_PORT}"
  export DB_USER="${CLOWDER_DATABASE_USERNAME}"
  export DB_PASSWORD="${CLOWDER_DATABASE_PASSWORD}"
  export DB_SSLMODE="${CLOWDER_DATABASE_SSLMODE}"
  export DB_CAFILE="/etc/pgbouncer/rdsca.cert"
  export PG_BOUNCER_LISTEN_PORT="${CLOWDER_WEBPORT}"

  db_cert="${CLOWDER_DATABASE_RDSCA}"
  >${DB_CAFILE}
  if [[ -n "${db_cert}" ]]; then
    echo "${db_cert}" > ${DB_CAFILE}
    unset db_cert
  fi

  [[ -z "${DB_PORT}" ]] && DB_PORT="5432"
fi
