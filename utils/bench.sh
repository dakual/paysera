#!/bin/bash
set -e

# Variables
DURATION="${DURATION:-300}"
CLIENTS="${CLIENTS:-10}"
THREADS="${THREADS:-2}"
DB_NAME="${DB_NAME:-postgres}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"
PGPORT="${PGPORT:-5432}"
PGHOST="${PGHOST:-localhost}"

export PGPASSWORD=$PGPASSWORD

# check pgbench. and install if not exist
install_pgbench() {
    echo "Checking for pgbench..."
    if command -v pgbench >/dev/null 2>&1; then
        echo "pgbench already installed."
    else
        echo "Installing pgbench..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update && sudo apt-get install -y postgresql-client
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y postgresql
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y postgresql
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install libpq
                brew link --force libpq
            fi
        else
            echo "Unsupported OS. Please install pgbench manually."
            exit 1
        fi
    fi
}

# prepare
initialize_pgbench() {
    echo "Checking if pgbench tables exist in database '$DB_NAME'..."
    TABLE_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -tAc "SELECT to_regclass('public.pgbench_branches');")

    if [[ "$TABLE_EXISTS" == "pgbench_branches" ]]; then
        echo "pgbench already initialized."
    else
        echo "Initializing pgbench tables..."
        pgbench -i -s 10 -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$DB_NAME"
    fi
}

# run
run_pgbench() {
    echo "Running pgbench for ${DURATION}s with ${CLIENTS} clients..."
    pgbench -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -T "$DURATION" -c "$CLIENTS" -j "$THREADS" -P 10 "$DB_NAME"
}

install_pgbench
initialize_pgbench
run_pgbench
