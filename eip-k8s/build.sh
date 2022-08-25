#!/bin/bash

kubectl create ns eip-base
echo "crate k8s ns : eip-base"

kubectl get ns | grep eip-base