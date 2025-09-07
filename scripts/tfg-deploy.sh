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

# Deploy opentwins
helm upgrade --install opentwins "$OPENTWINS_FORK_PATH" --wait --dependency-update \
             -f "./helms/opentwins/values.yaml" \
             --namespace opentwins

# Push harbor images
docker push --all-tags "${NODE_IP}:30002/library/buslocation"
docker push --all-tags "${NODE_IP}:30002/library/routes"
docker push --all-tags "${NODE_IP}:30002/library/emtmetrics"

# Deploy mysql
envsubst < ./secrets/mysql-secret.yaml | kubectl apply -f -
kubectl apply -f ./services/mysql.yaml
kubectl apply -f ./statefulsets/mysql.yaml

# Copy opentwins-influxdb2-auth to metrics namespace
kubectl get secret opentwins-influxdb2-auth -n opentwins -o yaml | \
    sed "s/namespace: opentwins/namespace: metrics/" | \
    kubectl apply -n metrics -f -

# Deploy components
envsubst < ./deployments/emtscraper/buslocation.yaml | kubectl apply -f -
envsubst < ./cronjobs/emtscraper/routes.yaml | kubectl apply -f -
envsubst < ./deployments/emtmetrics.yaml | kubectl apply -f -
kubectl apply -f services/emtmetrics.yaml
kubectl apply -f cronjobs/emtscraper/mysql-csv-loader.yaml

# Force first run of cronjobs
kubectl -n scraping create job --from=cronjob/emtscraper-routes emtscraper-routes-manual-initial
kubectl -n scraping create job --from=cronjob/mysql-csv-loader mysql-csv-loader-manual-initial
