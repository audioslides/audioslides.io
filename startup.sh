#!/usr/bin/env bash

# Mount google fuse
./gcsfuse.sh start

# start phx webserver
elixir --name $MY_POD_NAME@$MY_POD_IP -S mix phx.server --no-deps-check --no-compile --no-halt