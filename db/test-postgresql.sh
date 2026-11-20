#!/usr/bin/env bash
set -euo pipefail

container=$(docker run --detach --rm --network none --pull always \
    --env POSTGRES_HOST_AUTH_METHOD=trust \
    --env POSTGRES_DB=job_search_test \
    postgres:19)
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

docker exec --interactive "$container" psql -X --set=ON_ERROR_STOP=1 \
    --username=postgres --dbname=job_search_test --file=- < db/migrations/001_accounts_and_job_postings.sql
docker exec --interactive "$container" psql -X --set=ON_ERROR_STOP=1 \
    --username=postgres --dbname=job_search_test --file=- < db/tests/save_job_postings.sql
