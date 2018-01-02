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

RUN mix do compile --warnings-as-errors
RUN MIX_ENV=test mix credo --strict
RUN MIX_ENV=test mix coveralls

### DOCKER RUN IMAGE ###

FROM elixir:1.5.2-slim

# Setup ENV
ENV HOME=/opt/app \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH=./node_modules/.bin:$PATH \
    PORT=4000 \
    MIX_ENV=prod

# Add package sources
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list;
RUN echo "deb http://http.debian.net/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt-get update && \
        apt-get --allow-unauthenticated -y install \
        ffmpeg \
        gcsfuse \
        make \
        git \
        g++ \
        wget \
        curl \
        build-essential \
        locales \
        mysql-client \
        imagemagick && \
        curl -sL https://deb.nodesource.com/setup_8.x | bash && \
        apt-get -y install nodejs && \
        rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    update-ca-certificates --fresh

RUN mix do local.hex --force, local.rebar --force

WORKDIR /opt/app

# Install elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Install npm deps
ADD ./assets/package.json ./assets/package.json
RUN cd assets && npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets && \
    brunch build --production && \
    cd .. && \
    mix do compile, phx.digest

# Run the startup script
CMD ["./startup.sh"]
