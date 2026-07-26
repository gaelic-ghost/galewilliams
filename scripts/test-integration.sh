#!/usr/bin/env sh
set -eu

database_name="galewilliams_site_test"

docker compose up -d db redis

until docker compose exec -T db pg_isready -U galewilliams -d galewilliams_site >/dev/null 2>&1; do
  sleep 1
done

if ! docker compose exec -T db psql -U galewilliams -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$database_name'" | grep -q 1; then
  docker compose exec -T db createdb -U galewilliams "$database_name"
fi

RUN_DATABASE_INTEGRATION_TESTS=true \
DATABASE_HOST=127.0.0.1 \
DATABASE_PORT=5432 \
DATABASE_USERNAME=galewilliams \
DATABASE_PASSWORD=development-password \
DATABASE_NAME="$database_name" \
REDIS_URL=redis://127.0.0.1:6379 \
swift test --filter databaseIntegrationPersistsIntakeQueuesNotificationAndReviewsLead
