## Overview

Docker image packaging for Jackrabbit.

## Versions

- Stable: `gluufederation/jackrabbit:4.2.0_01`
- Unstable: `gluufederation/jackrabbit:4.2.1_dev`

Refer to [Changelog](./CHANGES.md) for details on new features, bug fixes, or older releases.

## Environment Variables

The following environment variables are supported by the container:

- `GLUU_MAX_RAM_PERCENTAGE`: Value passed to Java option `-XX:MaxRAMPercentage`.
- `GLUU_JAVA_OPTIONS`: Java options passed to entrypoint, i.e. `-Xmx1024m` (default to empty-string).
- `GLUU_WAIT_MAX_TIME`: How long the startup "health checks" should run (default to `300` seconds).
- `GLUU_WAIT_SLEEP_DURATION`: Delay between startup "health checks" (default to `10` seconds).
- `GLUU_JACKRABBIT_CLUSTER`: __EXPERIMENTAL__ Mark the instance as part of Jackrabbit cluster (default to `false`). Note the cluster requires Postgres.
- `GLUU_JACKRABBIT_POSTGRES_USER`: Postgres user (default to `postgres`).
- `GLUU_JACKRABBIT_POSTGRES_PASSWORD_FILE`: Absolute path to file contains Postgres password for user specified in `GLUU_JACKRABBIT_POSTGRES_USER` (default to `/etc/gluu/conf/postgres_password`).
- `GLUU_JACKRABBIT_POSTGRES_HOST`: Host or IP address of Postgres server (default to `localhost`).
- `GLUU_JACKRABBIT_POSTGRES_PORT`: Port of Postgres server (default to `5432`).
- `GLUU_JACKRABBIT_POSTGRES_DATABASE`: Postgres database being used for clustering (default to `jackrabbit`).
- `GLUU_JACKRABBIT_ANONYMOUS_ID_FILE`: Absolute path to file contains ID for anonymous user (default to `/etc/gluu/conf/jackrabbit_anonymous_id`).
- `GLUU_JACKRABBIT_ADMIN_ID_FILE`: Absolute path to file contains ID for admin user (default to `/etc/gluu/conf/jackrabbit_admin_id`).
