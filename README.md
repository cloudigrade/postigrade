# postigrade

Your friendly neighborhood uh.. pgbouncer?

Feed it the following env vars and it'll do the rest:

- DB_HOST
- DB_PORT - Optional, defaults to 5432
- DB_NAME
- DB_USER
- DB_PASSWORD

After startup pgBouncer will be listening on `0.0.0.0:5432`.
