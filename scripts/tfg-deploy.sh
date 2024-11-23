#!/bin/bash

# WARNING: This scripts asumes you already have harbor installed and set in
#           /etc/rancher/k3s/registries.yaml config file in your node(s)

# Create namespaces
kubectl apply -f ./deployments/namespaces.yaml

# Add helm charts
helm repo add ertis https://ertis-research.github.io/Helm-charts/

# Install helm charts
helm upgrade --install opentwins ertis/OpenTwins --wait --dependency-update --debug \
             -f "./helms/opentwins/values.yaml" \
             --namespace opentwins

# Deploy components
kubectl apply -f deployments/emtscraper.yaml
