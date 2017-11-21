FROM elixir:1.5.2-slim as dependency-cache

ENV HOME=/opt/app

RUN apt-get update && apt-get -y install git && rm -rf /var/lib/apt/lists/*
RUN mix do local.hex --force, local.rebar --force

# Cache elixir deps

WORKDIR /opt/app
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

###############################################################
FROM eu.gcr.io/symetics-com/audioslides-io-baseimage

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH \
    HOME=/opt/app

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /opt/app

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

# Cache elixir deps
COPY --from=dependency-cache $HOME/deps $HOME/deps
COPY --from=dependency-cache $HOME/_build $HOME/_build

# Same with npm deps
ADD ./assets/package.json ./assets/package.json
RUN cd assets && npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets && brunch build --production && cd .. && \
    mix do compile, phx.digest

# USER default

CMD ["./startup.sh", "start"]
