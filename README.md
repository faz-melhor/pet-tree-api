# PetreeApi

To start your Phoenix server:

  * Install PostgreSQL in your local machine
  * Export DATABASE_URL with your DB config info, eg. ``export DATABASE_URL=postgres://USER:PASSWORD@HOST:5432/DATABASE``
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

To run with Docker:

  * Create a .env file and set the DATABASE_URL with your config info eg. ``DATABASE_URL=postgres://postgres:postgres@db:5432/petree_api_dev``
  * Build images with `docker-compose build`
  * Create and migrate your database with `docker-compose run phoenix mix ecto.setup`
  * Start application with `docker-compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
