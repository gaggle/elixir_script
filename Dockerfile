FROM elixir:alpine as base

FROM base as build
WORKDIR /app
COPY mix.exs .
RUN mix deps.get
COPY lib lib
RUN mix deps.compile && mix escript.build

FROM base as release
COPY --from=build /app/elixir_script /usr/local/bin

ENTRYPOINT [ "elixir_script" ]
