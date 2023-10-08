FROM pkgxdev/pkgx as base
# Set locale to utf8, without this Elixir warns:
# > the VM is running with native name encoding of latin1 which may cause Elixir to malfunction as it expects utf8.
# > Please ensure your locale is set to UTF-8 (which can be verified by running "locale" in your shell)
# > or set the ELIXIR_ERL_OPTIONS="+fnu" environment variable
RUN apt-get -y install locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

FROM base as build
WORKDIR /action/workspace

# System dependencies
COPY ../.pkgx.yaml .
RUN eval "$(pkgx --internal.activate $PWD)"

# Mix dependencies
COPY ../mix.exs .
RUN eval "$(pkgx --internal.activate $PWD)" && mix deps.get

# Compile
COPY ../lib lib
RUN eval "$(pkgx --internal.activate $PWD)" && mix deps.compile
RUN eval "$(pkgx --internal.activate $PWD)" && mix escript.build

FROM base as release
COPY --from=build /root/.pkgx /root/.pkgx
COPY --from=build /action/workspace/.pkgx.yaml /usr/local/bin
COPY --from=build /action/workspace/elixir_script /usr/local/bin
RUN echo '#!/bin/sh\n\
eval "$(pkgx --internal.activate /usr/local/bin)"\n\
exec /usr/local/bin/elixir_script "$@"' > /usr/local/bin/elixir_script_wrapper && \
chmod +x /usr/local/bin/elixir_script_wrapper

ENTRYPOINT ["elixir_script_wrapper"]
