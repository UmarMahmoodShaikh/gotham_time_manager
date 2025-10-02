#!/bin/sh
# Exit on any error
set -e

# Ensure the Phoenix server starts in production mode
export PHX_SERVER=true

# Only perform database checks in local development (not on Heroku)
if [ -z "$DYNO" ]; then
  echo "===> Local development environment detected"

  # Load .env file if it exists (local dev only)
  if [ -f ".env" ]; then
    echo "===> Loading environment from .env file..."
    export $(grep -v '^#' .env | xargs)
  fi

  # Check if netcat is available and DATABASE_URL is set
  if command -v nc >/dev/null 2>&1 && [ -n "$DATABASE_URL" ]; then
    # Extract host and port from DATABASE_URL
    DB_HOST=$(echo "$DATABASE_URL" | sed -E 's#^[^/]+//[^@]+@([^:/]+).*#\1#')
    DB_PORT=$(echo "$DATABASE_URL" | sed -E 's#^[^/]+//[^@]+@[^:]+:([0-9]+).*#\1#')

    # Default to 5432 if port extraction failed
    if [ -z "$DB_PORT" ] || [ "$DB_PORT" = "$DATABASE_URL" ]; then
      DB_PORT=5432
    fi

    echo "===> Waiting for Postgres at $DB_HOST:$DB_PORT..."
    until nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
      echo "Postgres is unavailable - sleeping"
      sleep 1
    done
    echo "===> Postgres is ready!"
  else
    echo "===> Skipping database check (nc not available or DATABASE_URL not set)"
  fi
else
  echo "===> Heroku environment detected - skipping database checks"
fi

echo "===> Starting Phoenix application..."

# Start the Phoenix application using the release binary
exec bin/gotham_time_manager start