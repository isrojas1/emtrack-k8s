#!/bin/bash

kubectl create namespace harbor

helm repo add harbor https://helm.goharbor.io

# WARNING: this way has not been tested, refer to https://goharbor.io/docs/2.12.0/install-config/harbor-ha-helm/
#           if problems arise
helm install harbor harbor/harbor -f ./helms/harbor/values.yaml -n harbor
