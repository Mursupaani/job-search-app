#!/usr/bin/env bash
set -euo pipefail

container=$(docker run --detach --rm --network none \
    --env POSTGRES_HOST_AUTH_METHOD=trust \
    --env POSTGRES_DB=job_search_test \
    postgres:19.0@sha256:bb6e70add742cd868fb62cb3b2f67d1dd2bdd2b65a521e778420748753687c60)
trap 'docker stop "$container" >/dev/null' EXIT

# The image starts a temporary socket-only server to initialize the database.
# Checking TCP inside the container waits for the final server.
for attempt in {1..30}; do
    if docker exec "$container" pg_isready --quiet --host=127.0.0.1 --username=postgres; then
        break
    fi
    if (( attempt == 30 )); then
        echo "The disposable PostgreSQL server did not become ready." >&2
        docker logs "$container" >&2
        exit 1
    fi
    sleep 1
done

run_sql() {
    docker exec --interactive "$container" psql -X --set=ON_ERROR_STOP=1 \
        --username=postgres --dbname=job_search_test --file=-
}

run_sql < db/migrations/001_accounts_and_job_postings.sql
if [[ "${1:-}" == --verify-password ]]; then
    run_sql < db/migrations/002_account_passwords.sql
    test_image=$(docker build --quiet server)
    # Share PostgreSQL's loopback interface without publishing a database port.
    docker run --rm --network "container:$container" \
        --env PGHOST=127.0.0.1 --env PGUSER=postgres --env PGDATABASE=job_search_test \
        "$test_image"
else
    run_sql < db/tests/save_job_postings.sql
fi
