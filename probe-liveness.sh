#!/bin/bash

source /clowder_init.sh

/usr/bin/pg_isready -h localhost -p ${PG_BOUNCER_LISTEN_PORT} -U "${DB_USER}" | grep "accepting connections"
exit $?

