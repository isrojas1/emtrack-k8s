#!/bin/bash

# Set env variables
if [ $# -ne 1 ]; then
  echo "Usage: ./scripts/connections.sh <ENV_FILE>"
  exit 1
fi

ENV_FILE=$1
source "$ENV_FILE" || { echo "Error sourcing env file"; exit 1; }

send_put_request() {
    local url="$1"
    local json_file="$2"

    curl -X PUT -H "Content-Type: application/json" \
         -u "$DITTO_API_USERNAME:$DITTO_API_PASSWORD" \
         -H 'Accept: application/json' \
         -d @"$json_file" \
         "$url"
}

send_put_request "http://${NODE_IP}:30525/api/2/connections/mosquitto-emtscraper-source-connection" "./dittoapi/mosquitto-emtscraper-source-connection.json"
