#!/usr/bin/env bash

# Mount google fuse
./gcsfuse.sh start

# start phx webserver
mix phx.server