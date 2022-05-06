#!/bin/bash

docker stop postgres && docker rm postgres

docker run -d \
        --name postgres \
        --restart=always \
        -p 5432:5432 \
        -e POSTGRES_PASSWORD=123456 \
        -v /home/postgres/data:/var/lib/postgresql/data \
        postgres:14.2
