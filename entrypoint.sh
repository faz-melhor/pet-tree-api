#!/bin/bash
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -h $DB_HOST -U $DB_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -Atqc "\\list ${DB_NAME/\?/$MIX_ENV}"` ]]; then
  echo "Database ${DB_NAME/\?/$MIX_ENV} does not exist. Creating..."
  mix ecto.setup
  echo "Database ${DB_NAME/\?/$MIX_ENV} created."
fi

# Check new dependencies and new migrations then start server
mix deps.get && mix ecto.migrate && mix phx.server
