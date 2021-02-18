#! /bin/bash

echo "stop docker container"

docker stop $(docker ps -q)

echo "rm docker container"

docker rm $(docker ps -qa)
