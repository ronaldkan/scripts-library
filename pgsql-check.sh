#! /bin/bash
# get info from k8s cluster
export PGPASSWORD=$(kubectl get secrets/pg-secret -n default -o=jsonpath='{ .data }' | jq -r '."values.yaml"' | base64 -d | yq -r ' .secrets.PG_ADMIN_PASSWORD');
export PGHOST=$(kubectl get configmap/pg-config -n default -o=jsonpath='{ .data }' | jq -r '."values.yaml"' | yq -r '.env.PG_HOST');
PGDB_CHECK=$(psql -d postgres -h $PGHOST -p 5432 -U root -XtAc "SELECT 1 FROM pg_database WHERE datname='"$PGSQL_NAME"'")
if [ "${PGDB_CHECK}" != "1" ]; then
    # Example pgsql script
    psql -d postgres -h $PGHOST -p 5432 -U root -c "CREATE DATABASE $PGSQL_NAME;";
    psql -d postgres -h $PGHOST -p 5432 -U root -c "GRANT ALL PRIVILEGES ON DATABASE $PGSQL_NAME TO \"$POSTGRESQL_USERNAME\";";
fi
