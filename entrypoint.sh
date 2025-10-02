#!/bin/bash
# exit if any command fails
set -e

# Load environment variables from .env if it exists
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "===> Checking Postgres at $POSTGRES_HOST:$POSTGRES_PORT..."
# Wait until Postgres is ready
until nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 1
done
echo "===> Postgres is ready!"

echo "===> Running migrations..."
# Run migrations with your Release module
bin/gotham_time_manager eval "GothamTimeManager.Release.migrate"

echo "===> Starting Phoenix app..."
# Start the Phoenix application
exec bin/gotham_time_manager start
