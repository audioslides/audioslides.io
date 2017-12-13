################################################################################################
################################################################################################
FROM elixir:1.5.2-slim as elixir-dependency-cache

# Setup ENV
ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force
ADD mix.exs mix.lock $HOME/

RUN mix deps.get

################################################################################################
################################################################################################

FROM node:8 as node-asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=elixir-dependency-cache /opt/app/deps/phoenix $HOME/deps/phoenix
COPY --from=elixir-dependency-cache /opt/app/deps/phoenix_html $HOME/deps/phoenix_html

WORKDIR $HOME/assets

COPY assets/ ./
RUN npm install
RUN ./node_modules/.bin/brunch build --production

################################################################################################
################################################################################################
FROM elixir:1.5.2-slim as elixir-builder

# Setup ENV
ENV HOME=/opt/app \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Add package sources
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list;
RUN echo "deb http://http.debian.net/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt-get update && \
        apt-get --allow-unauthenticated -y install \
        locales

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN mix do local.hex --force, local.rebar --force

WORKDIR /opt/app

######## COMPILE DEPS ##########
# Copy cached dependency modules
COPY --from=elixir-dependency-cache /opt/app/deps $HOME/deps

ADD mix.exs mix.lock $HOME/

# Compile deps
RUN mix deps.compile
######## COMPILE DEPS ##########

######## GET AND DIGEST ASSETS ##########
# Copy compiled javascript modules
COPY --from=node-asset-builder $HOME/priv/static/ ./priv/static/

# Run frontend build, compile, and digest assets
RUN mix phx.digest
######## GET AND DIGEST ASSETS ##########

ADD . .

RUN mix do compile

# Run the startup script
#CMD ["./startup.sh"]

###########
# minimal run image
###########
# FROM alpine:latest
FROM elixir:1.5.2-slim

# Setup ENV
ENV HOME=/opt/app \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH=./node_modules/.bin:$PATH \
    PORT=4000 \
    MIX_ENV=prod

RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list;
RUN echo "deb http://http.debian.net/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list

# Install container deps
RUN apt-get update && \
        apt-get --allow-unauthenticated -y install \
        mysql-client \
        ffmpeg \
        locales \
        gcsfuse \
        imagemagick \
        ca-certificates

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    update-ca-certificates --fresh

RUN mix local.hex --force

WORKDIR /opt/app

# copy compiled exilir app
COPY --from=elixir-builder /opt/app/_build/ ./_build
COPY --from=elixir-builder /opt/app/deps/ ./deps

# Copy compiled javascript modules
COPY --from=elixir-builder /opt/app/priv/static/ ./priv/static/

# Copy startup scripts
COPY --from=elixir-builder /opt/app/gcsfuse.sh ./gcsfuse.sh
COPY --from=elixir-builder /opt/app/startup.sh ./startup.sh
COPY --from=elixir-builder /opt/app/mix.exs ./mix.exs
COPY --from=elixir-builder /opt/app/mix.lock ./mix.lock
COPY --from=elixir-builder /opt/app/config/config.exs ./config/config.exs
COPY --from=elixir-builder /opt/app/config/prod.exs ./config/prod.exs

# Run the startup script
CMD ["./startup.sh"]