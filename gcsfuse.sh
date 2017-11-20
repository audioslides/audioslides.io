#!/usr/bin/env bash

# This script is used in kubernetes postStart hook to connect to the GCS Fuse Bucket
case "$1" in
  start)
    echo "Starting gcsfuse"
    mkdir priv/static/content
    echo $GOOGLE_GCP_CREDENTIALS >> key.json
    gcsfuse --key-file=/opt/app/key.json audioslides-io-prod priv/static/content
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