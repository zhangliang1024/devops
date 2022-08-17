#!/bin/bash

docker stop minio && docker rm minio

docker run --name minio \
  -p 9000:9000 \
  -p 9001:9001 \
  -d --restart=always \
  -e "MINIO_ROOT_USER=minio" \
  -e "MINIO_ROOT_PASSWORD=minio" \
  -v /usr/local/minio/data:/data \
  minio/minio server --console-address ":9001"