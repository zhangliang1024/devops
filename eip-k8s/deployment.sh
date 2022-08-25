#!/bin/bash

kubectl apply -f nginx-deployment.yaml

watch kubectl get pods -n eip-base

