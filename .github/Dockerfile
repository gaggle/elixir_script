FROM pkgxdev/pkgx AS base
# Set locale to utf8, without this Elixir warns:
# > the VM is running with native name encoding of latin1 which may cause Elixir to malfunction as it expects utf8.
# > Please ensure your locale is set to UTF-8 (which can be verified by running "locale" in your shell)
# > or set the ELIXIR_ERL_OPTIONS="+fnu" environment variable
RUN apt-get update && apt-get -y install locales ca-certificates && rm -rf /var/lib/apt/lists/*
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create pkgx_env helper script that executes commands with dependencies from .pkgx.yaml
COPY --chmod=755 <<'EOF' /usr/local/bin/pkgx_env
#!/bin/sh
set -eu

CONFIG_PATH="/usr/local/bin/.pkgx.yaml"
PKGX_DEPS=$(pkgx yq eval '.dependencies | to_entries | map("+" + .key + "@" + (.value | sub("^="; ""))) | join(" ")' "$CONFIG_PATH")
exec pkgx $PKGX_DEPS "$@"
EOF
COPY .pkgx.yaml /usr/local/bin/

FROM base AS build
WORKDIR /action/workspace

# Mix dependencies
COPY mix.exs mix.lock ./
RUN pkgx_env mix deps.get && pkgx_env mix deps.compile

# Compile
COPY lib lib
RUN pkgx_env mix compile
RUN pkgx_env mix escript.build

FROM base AS release
WORKDIR /usr/local/bin

COPY --from=build /action/workspace/elixir_script /usr/local/bin/elixir_script

ENTRYPOINT ["pkgx_env", "/usr/local/bin/elixir_script"]
