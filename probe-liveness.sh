#!/bin/bash

/usr/pgsql-13/bin/pg_isready -h localhost -p 5432 -U "${DB_USER}" | grep "accepting connections"
exit $?

