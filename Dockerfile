FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY . /app

CMD mix deps.get && mix ecto.setup && mix phx.server
