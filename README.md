# Pet Tree API

![Elixir CI](https://github.com/faz-melhor/pet-tree-api/workflows/Elixir%20CI/badge.svg)

To start your Phoenix server locally:

  * Install PostgreSQL in your local machine
  * Export required environment variables:
    - `export MIX_ENV=dev; export DB_HOST=localhost; export DB_NAME=petree_api_?; export DB_USER=USERNAME; export DB_PASSWORD=PASSWORD`
    - The `?` in the database name will be replaced with the value defined in `MIX_ENV`
  * Install dependencies with `mix deps.get`
  * Create, migrate and seed your database with `mix ecto.setup` (will seed an admin user `email: admin@pettree.com, password: admin`)
  * Start Phoenix endpoint with `mix phx.server`

To start your Phoenix server using Docker:

  * Copy .env-sample and rename it to .env, open it and fill all the information required in the variables defined
  * Build images with `docker compose build`
  * Start application with `docker compose up`, the database will be created and migrated automatically
  * To run tests `docker compose run --rm -e MIX_ENV=test phoenix mix test`
  * An admin user will be seeded automatically (`email: admin@pettree.com, password: admin`)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser or send HTTP requests to [`localhost:4000/v1`](http://localhost:4000).

## API Specification

* A API Specification can be found inside docs folder or online [here](https://faz-melhor.stoplight.io/docs/pet-tree/pet-tree-api.v1.yaml).
* A mock server is available in this address: https://faz-melhor.stoplight.io/mocks/faz-melhor/pet-tree/2454148
