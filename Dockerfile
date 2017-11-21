FROM elixir:1.5.2-slim as dependency-cache

ENV HOME=/opt/app

RUN apt-get update && apt-get -y install git && rm -rf /var/lib/apt/lists/*
RUN mix do local.hex --force, local.rebar --force

RUN apt-get update && apt-get -y install \
        git make g++ wget curl build-essential locales \
        mysql-client \
        imagemagick \
        libav-tools  && \
        curl -sL https://deb.nodesource.com/setup_8.x | bash && \
        apt-get -y install nodejs && \
        rm -rf /var/lib/apt/lists/*

# Install FFMpeg
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list
RUN echo "deb http://http.debian.net/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y ffmpeg

# Install gcsfuse (Google Cloud Storage)
# Info: Kubernetes need to start this container as privileged https://kubernetes.io/docs/concepts/workloads/pods/pod/#privileged-mode-for-pod-containers
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list;
RUN apt-get update && \
    apt-get -y --allow-unauthenticated install gcsfuse

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    update-ca-certificates --fresh

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
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD ./assets/package.json ./assets/package.json
RUN cd assets && npm install

WORKDIR /opt/app

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets && \
    brunch build --production && \
    cd .. && \
    mix do compile, phx.digest

# USER default

CMD ["./startup.sh"]
