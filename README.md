# PetreeApi

To start your Phoenix server local:

  * Install PostgreSQL in your local machine
  * Export required environment variables:
    - `export MIX_ENV=dev; export DB_HOST=localhost; export DB_NAME=petree_api_?; export DB_USER=USERNAME; export DB_PASSWORD=PASSWORD`
    - The `?` in the database name will be replaced with the value defined in `MIX_ENV`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

To start your Phoenix server using Docker:

  * Copy .env-sample and rename it to .env, open it and fill all the information required in the variables defined
  * Build images with `docker-compose build`
  * Start application with `docker-compose up`, the database will be created and migrated automatically
  * To run tests `docker-compose run -e MIX_ENV=test phoenix mix test`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
