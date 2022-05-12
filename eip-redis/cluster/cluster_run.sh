#! /bin/bash

HOST_IP=$1
if [ -n "$1" ] ;then
    echo "参数为服务器IP，当前值是：$1"
else
    echo "请输入服务器IP参数，例如: sh build.sh 192.168.XX.X"
    exit 1;
fi

echo "redis cluster start"

docker run --restart always --name redis-cluster-7001 --net host --privileged=true -v ${PWD}/7001/redis7001.conf:/usr/local/redis-cluster/7001/redis7001.conf -v ${PWD}/7001/data:/usr/local/redis-cluster/7001/data -d redis redis-server /usr/local/redis-cluster/7001/redis7001.conf

docker run --restart always --name redis-cluster-7002 --net host --privileged=true -v ${PWD}/7002/redis7002.conf:/usr/local/redis-cluster/7002/redis7002.conf -v ${PWD}/7002/data:/usr/local/redis-cluster/7002/data -d redis redis-server /usr/local/redis-cluster/7002/redis7002.conf

docker run --restart always --name redis-cluster-7003 --net host --privileged=true -v ${PWD}/7003/redis7003.conf:/usr/local/redis-cluster/7003/redis7003.conf -v ${PWD}/7003/data:/usr/local/redis-cluster/7003/data -d redis redis-server /usr/local/redis-cluster/7003/redis7003.conf

docker run --restart always --name redis-cluster-7004 --net host --privileged=true -v ${PWD}/7004/redis7004.conf:/usr/local/redis-cluster/7004/redis7004.conf -v ${PWD}/7004/data:/usr/local/redis-cluster/7004/data -d redis redis-server /usr/local/redis-cluster/7004/redis7004.conf

docker run --restart always --name redis-cluster-7005 --net host --privileged=true -v ${PWD}/7005/redis7005.conf:/usr/local/redis-cluster/7005/redis7005.conf -v ${PWD}/7005/data:/usr/local/redis-cluster/7005/data -d redis redis-server /usr/local/redis-cluster/7005/redis7005.conf

docker run --restart always --name redis-cluster-7006 --net host --privileged=true -v ${PWD}/7006/redis7006.conf:/usr/local/redis-cluster/7006/redis7006.conf -v ${PWD}/7006/data:/usr/local/redis-cluster/7006/data -d redis redis-server /usr/local/redis-cluster/7006/redis7006.conf


echo "redis cluster end"

sleep 3

docker ps

sleep 3

echo "begin make cluser ..."

# 指定当前服务器IP
HOST_IF=$(ip route|grep default|head -n1|cut -d' ' -f5)
HOST_IP=$(ip a|grep "$HOST_IF$"|head -n1|awk '{print $2}'|cut -d'/' -f1)

echo $HOST_IP

docker exec -it redis-cluster-7001 redis-cli --cluster create $HOST_IP:7001 $HOST_IP:7002 $HOST_IP:7003 $HOST_IP:7004 $HOST_IP:7005 $HOST_IP:7006 --cluster-replicas 1

docker exec -it redis-cluster-7001 /bin/bash




