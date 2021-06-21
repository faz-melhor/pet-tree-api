FROM bitwalker/alpine-elixir-phoenix:latest

RUN apk update && \
  apk add postgresql-client

WORKDIR /app

COPY . /app

#CMD mix deps.get && mix ecto.setup && mix phx.server
CMD ["/app/entrypoint.sh"]
