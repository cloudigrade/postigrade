#!/bin/sh

set -e

PG_CONFIG_DIR=/etc/pgbouncer

# md5 and write the password
pass="md5$(echo -n "$DB_PASSWORD$DB_USER" | md5sum | cut -f 1 -d ' ')"
echo "\"$DB_USER\" \"$pass\"" >> ${PG_CONFIG_DIR}/userlist.txt
echo "Wrote authentication credentials to ${PG_CONFIG_DIR}/userlist.txt"

# pgbouncer config
printf "\
[databases]
${DB_NAME} = host=${DB_HOST} port=${DB_PORT:-5432} dbname=${DB_NAME} user=${DB_USER}

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 5432
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
admin_users = postgres
" > ${PG_CONFIG_DIR}/pgbouncer.ini
echo "Wrote pgbouncer config to ${PG_CONFIG_DIR}/pgbouncer.ini"

echo "Starting $*..."
exec "$@"
