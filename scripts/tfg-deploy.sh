#!/bin/bash

# WARNING: This scripts asumes you already have harbor installed and set in
#           /etc/rancher/k3s/registries.yaml config file in your node(s)

# Set env variables
if [ $# -ne 1 ]; then
  echo "Usage: ./scripts/tfg-deploy.sh <ENV_FILE>"
  exit 1
fi

ENV_FILE=$1
source "$ENV_FILE" || { echo "Error sourcing env file"; exit 1; }

# Create namespaces
kubectl apply -f ./deployments/namespaces.yaml

# Add helm charts
helm repo add ertis https://ertis-research.github.io/Helm-charts/

# Install helm charts
helm upgrade --install opentwins ertis/OpenTwins --wait --dependency-update \
             -f "./helms/opentwins/values.yaml" \
             --namespace opentwins

# Use my local fork
# helm upgrade --install opentwins ../../OpenTwins --wait --dependency-update \
#              -f "./helms/opentwins/values.yaml" \
#              --namespace opentwins

# Push harbor images
docker push --all-tags "${NODE_IP}:30002/library/buslocation"
docker push --all-tags "${NODE_IP}:30002/library/routes"

# Deploy mysql
kubectl create namespace mysql
envsubst < ./secrets/mysql-secret.yaml | kubectl apply -f -
kubectl apply -f ./services/mysql.yaml
kubectl apply -f ./statefulsets/mysql.yaml
kubectl create secret generic mysql-secret \
  --from-literal=loader_password="$MYSQL_PASSWORD" \

# Deploy components
envsubst < ./deployments/emtscraper/buslocation.yaml | kubectl apply -f -
envsubst < ./cronjobs/emtscraper/routes.yaml | kubectl apply -f -
kubectl apply -f cronjobs/emtscraper/mysql-csv-loader.yaml
