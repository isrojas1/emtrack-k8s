#!/bin/bash

kubectl rollout restart deployment/opentwins-mosquitto -n opentwins
kubectl rollout restart deployment/opentwins-telegraf -n opentwins

kubectl rollout restart deployment/emtscraper-buslocation -n scraping
