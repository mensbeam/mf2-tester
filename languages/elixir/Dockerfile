FROM elixir:1.19.5
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY deps/ deps/
RUN mkdir -p languages/elixir
WORKDIR /app/deps
RUN mix local.hex --force && mix local.rebar --force
RUN MIX_XDG=1 MIX_QUIET=1 mix deps.get
RUN MIX_XDG=1 MIX_QUIET=1 mix escript.build
RUN cp /app/languages/elixir/test-one /usr/local/bin/test-one-elixir
