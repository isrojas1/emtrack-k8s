#!/bin/bash

helm upgrade --install opentwins ertis/OpenTwins --wait --dependency-update --debug \
             -f "./helm/values.yaml" \
             --namespace opentwins
