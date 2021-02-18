#! /bin/bash

echo "redis cluster start"

docker run --restart always --name redis-cluster-7001 --net host --privileged=true -v /toony/redis-cluster/7001/redis7001.conf:/usr/local/redis-cluster/7001/redis7001.conf -v /toony/redis-cluster/7001/data:/usr/local/redis-cluster/7001/data -d redis redis-server /usr/local/redis-cluster/7001/redis7001.conf

docker run --restart always --name redis-cluster-7002 --net host --privileged=true -v /toony/redis-cluster/7002/redis7002.conf:/usr/local/redis-cluster/7002/redis7002.conf -v /toony/redis-cluster/7002/data:/usr/local/redis-cluster/7002/data -d redis redis-server /usr/local/redis-cluster/7002/redis7002.conf

docker run --restart always --name redis-cluster-7003 --net host --privileged=true -v /toony/redis-cluster/7003/redis7003.conf:/usr/local/redis-cluster/7003/redis7003.conf -v /toony/redis-cluster/7003/data:/usr/local/redis-cluster/7003/data -d redis redis-server /usr/local/redis-cluster/7003/redis7003.conf

docker run --restart always --name redis-cluster-7004 --net host --privileged=true -v /toony/redis-cluster/7004/redis7004.conf:/usr/local/redis-cluster/7004/redis7004.conf -v /toony/redis-cluster/7004/data:/usr/local/redis-cluster/7004/data -d redis redis-server /usr/local/redis-cluster/7004/redis7004.conf

docker run --restart always --name redis-cluster-7005 --net host --privileged=true -v /toony/redis-cluster/7005/redis7005.conf:/usr/local/redis-cluster/7005/redis7005.conf -v /toony/redis-cluster/7005/data:/usr/local/redis-cluster/7005/data -d redis redis-server /usr/local/redis-cluster/7005/redis7005.conf

docker run --restart always --name redis-cluster-7006 --net host --privileged=true -v /toony/redis-cluster/7006/redis7006.conf:/usr/local/redis-cluster/7006/redis7006.conf -v /toony/redis-cluster/7006/data:/usr/local/redis-cluster/7006/data -d redis redis-server /usr/local/redis-cluster/7006/redis7006.conf


echo "redis cluster end"

sleep 3

docker ps

sleeep 3

echo "begin make cluser ..."

docker exec -it redis-cluster-7001 redis-cli --cluster create 182.61.41.102:7001 182.61.41.102:7002 182.61.41.102:7003 182.61.41.102:7004 182.61.41.102:7005 182.61.41.102:7006 --cluster-replicas 1

docker exec -it redis-cluster-7001 /bin/bash




