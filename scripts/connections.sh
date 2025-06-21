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
    local username="$2"
    local password="$3"
    local json_file="$4"

    echo "Sending PUT request to url: $url"

    curl -v -X PUT -H "Content-Type: application/json" \
         -u "$username:$password" \
         -H 'Accept: application/json' \
         -d @"$json_file" \
         "$url"
}

send_post_request() {
    local url="$1"
    local username="$2"
    local password="$3"
    local json_file="$4"

    echo "Sending POST request to url: $url"

    curl -v -X POST -H "Content-Type: application/json" \
         -u "$username:$password" \
         -H 'Accept: application/json' \
         -d @"$json_file" \
         "$url"
}

# Create grafana's mysql connection
send_post_request "http://${NODE_IP}:30718/api/datasources" "$GRAFANA_API_USERNAME" "$GRAFANA_API_PASSWORD" <(envsubst < ./apis/grafana/mysql-datasource.json)

# Create ditto's mosquitto-emtscraper-source-connection
send_put_request "http://${NODE_IP}:30525/api/2/connections/mosquitto-emtscraper-source-connection" "$DITTO_API_USERNAME" "$DITTO_API_PASSWORD" "./apis/ditto/mosquitto-emtscraper-source-connection.json"

# Create grafana's ubicacion-bus-dashboard
send_post_request "http://${NODE_IP}:30718/api/dashboards/db" "$GRAFANA_API_USERNAME" "$GRAFANA_API_PASSWORD" "./apis/grafana/ubicacion-bus-dashboard.json"

# Create grafana's ubicacion-buses-actual-dashboard
send_post_request "http://${NODE_IP}:30718/api/dashboards/db" "$GRAFANA_API_USERNAME" "$GRAFANA_API_PASSWORD" "./apis/grafana/ubicacion-buses-actual-dashboard.json"

