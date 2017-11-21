FROM eu.gcr.io/symetics-com/audioslides-io-baseimage

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
