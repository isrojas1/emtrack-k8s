#!/bin/bash

# Function to check if the remote machine is online
check_remote() {
    local remote_host="$1"
    local timeout="$2"
    local start_time=$(date +%s)

    echo "Checking if $remote_host is back online..."

    while true; do
        # Ping the remote host
        if ping -c 1 "$remote_host" &> /dev/null; then
            echo "$remote_host is back online!"
            return 0
        fi

        # Check if the timeout has been reached
        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$timeout" ]; then
            echo "Timeout reached. $remote_host is still offline."
            return 1
        fi

        # Wait for a few seconds before the next check
        sleep 5
    done
}

# Set env variables
if [ $# -ne 1 ]; then
  echo "Usage: ./scripts/tfg-deploy.sh <ENV_FILE>"
  exit 1
fi

ENV_FILE=$1
source "$ENV_FILE" || { echo "Error sourcing env file"; exit 1; }

# Copy registries.yaml
envsubst < files/registries.yaml | ssh ivan@${NODE_IP} "sudo tee -a /etc/rancher/k3s/registries.yaml"
ssh ivan@${NODE_IP} "sudo systemctl restart k3s"
# ssh ivan@${NODE_IP} "sudo reboot now"
# sleep 5
# check_remote "$NODE_IP" 120

# Deploy harbor
kubectl create namespace harbor
helm repo add harbor https://helm.goharbor.io
envsubst < ./helms/harbor/values.yaml | helm upgrade --install harbor harbor/harbor -f - -n harbor
