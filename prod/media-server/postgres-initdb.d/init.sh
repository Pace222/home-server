#!/bin/bash

set -e
set -u

function create_user_and_databases() {
    local owner=$(echo $1 | awk -F: '{print $1}')
    local password=$(echo $1 | awk -F: '{print $2}')
    local databases=$(echo $1 | awk -F: '{print $3}')

    echo "Creating user '$owner' and databases: $databases"

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE USER "$owner" WITH PASSWORD '$password';
EOSQL

    IFS=',' read -ra DB_ARRAY <<< "$databases"
    for db in "${DB_ARRAY[@]}"; do
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
            CREATE DATABASE "$db";
            GRANT ALL PRIVILEGES ON DATABASE "$db" TO "$owner";
EOSQL
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
            GRANT ALL ON SCHEMA public TO "$owner";
EOSQL
    done
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ';' ' '); do
		create_user_and_databases $db
	done
	echo "Multiple databases created"
fi
