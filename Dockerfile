FROM elixir:1.5.2-slim as builder

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
#CMD ["./startup.sh"]

###########
# minimal run image
###########
# FROM alpine:latest
FROM debian:jessie

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

WORKDIR /opt/app

RUN mix do local.hex --force

# copy compiled exilir app
COPY --from=builder /opt/app/_build/ ./_build
COPY --from=builder /opt/app/deps/ ./deps

# Copy compiled javascript modules
COPY --from=builder /opt/app/priv/static/ ./priv/static/

# Copy startup scripts
COPY --from=builder /opt/app/gcsfuse.sh ./gcsfuse.sh
COPY --from=builder /opt/app/startup.sh ./startup.sh
COPY --from=builder /opt/app/mix.exs ./mix.exs
COPY --from=builder /opt/app/mix.lock ./mix.lock
COPY --from=builder /opt/app/config/config.exs ./config/config.exs
COPY --from=builder /opt/app/config/prod.exs ./config/prod.exs

# Run the startup script
CMD ["./startup.sh"]