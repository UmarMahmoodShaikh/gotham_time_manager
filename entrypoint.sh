#!/bin/sh
# exit if any command fails
set -e

# Load environment variables from .env if it exists (local dev only)
if [ -f ".env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' .env | xargs)
fi

# Ensure the Phoenix server starts in releases
export PHX_SERVER=true

# Determine Postgres host and port
DB_HOST="${POSTGRES_HOST:-}"
DB_PORT="${POSTGRES_PORT:-}"

if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ]; then
  if [ -n "$DATABASE_URL" ]; then
    # Extract host and port from DATABASE_URL (ecto/postgres URL)
    # Examples: postgres://user:pass@host:5432/db or ecto://user@host/db
    DB_HOST=$(printf "%s" "$DATABASE_URL" | sed -E 's#^[a-z]+://([^:@/]+)(:[0-9]+)?/.*$#\1#')
    DB_PORT=$(printf "%s" "$DATABASE_URL" | sed -nE 's#^[a-z]+://[^:@/]+:([0-9]+)/.*$#\1#p')
    [ -z "$DB_PORT" ] && DB_PORT=5432
  fi
fi

if [ -n "$DB_HOST" ] && [ -n "$DB_PORT" ]; then
  echo "===> Checking Postgres at $DB_HOST:$DB_PORT..."
  # Wait until Postgres is ready (nc from busybox is usually available on Alpine)
  until nc -z "$DB_HOST" "$DB_PORT"; do
    sleep 1
  done
  echo "===> Postgres is ready!"
else
  echo "===> WARNING: Database host/port not set; skipping DB wait. Ensure DATABASE_URL is configured."
fi

echo "===> Running migrations..."
# Run migrations with your Release module (idempotent)
bin/gotham_time_manager eval "GothamTimeManager.Release.migrate"

echo "===> Starting Phoenix app..."
# Start the Phoenix application
exec bin/gotham_time_manager start
