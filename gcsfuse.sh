#!/usr/bin/env bash

# The following part carries out specific functions depending on arguments.
case "$1" in
  start)
    echo "Starting gcsfuse"
    mkdir priv/static/fuse
    echo $GOOGLE_GCP_CREDENTIALS >> key.json
    gcsfuse --key-file=/opt/app/key.json audioslides-io-prod priv/static/fuse
    rm key.json
    ;;
  stop)
    echo "Stopping gcsfuse(not implemented yet)"
    ;;
  *)
    echo "Usage: /etc/init.d/gcsfuse {start|stop}"
    exit 1
    ;;
esac

exit 0