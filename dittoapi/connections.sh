source .env

send_put_request() {
    local url="$1"
    local json_file="$2"

    curl -X PUT -H "Content-Type: application/json" \
         -u "$DITTO_API_USERNAME:$DITTO_API_PASSWORD" \
         -H 'Accept: application/json' \
         -d @"$json_file" \
         "$url"
}

send_put_request "http://192.168.1.101:30525/api/2/connections/mosquitto-data-source-connection" "./dittoapi/mosquitto-data-source-connection.json"
