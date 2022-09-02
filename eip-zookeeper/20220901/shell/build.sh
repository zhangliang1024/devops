#!/bin/bash

count=3                        #节点数
network_name="net-zoo"         #集群所在网络名
client_port_start=2181         #集群绑定主机初始节点（不包括）
name_prefix="zoo"              #集群容器名前缀

#停止
zookeeper_stop(){
  for i in $(seq 1 $count); do
    zoo_name="$name_prefix$i"
    echo 停止容器:`sudo docker stop $zoo_name`
  done
}
#启动
zookeeper_start(){
  for i in $(seq 1 $count); do
    zoo_name="$name_prefix$i"
    echo 启动容器:`sudo docker start $zoo_name`
  done
  #打印集群信息
  if [ -z "$client_servers" ];then
    if [ -z "$local_ip" ];then
      ips=(`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | tr '\n' ' '`)
      index=${#ips[@]}
      index=`expr $index - 1`
      local_ip=${ips[$index]}
    fi
    for i in $(seq 1 $count); do
      port=`expr $i + $client_port_start` # 客户端服务接口
      if [ $i -eq $count ];then
        client_servers="${client_servers}${local_ip}:${port}"
      else
        client_servers="${client_servers}${local_ip}:${port},"
      fi
    done
  fi
  echo 集群服务地址:$client_servers
}
#停止并移除
zookeeper_down(){
  zookeeper_stop
  for i in $(seq 1 $count); do
    zoo_name="$name_prefix$i"
    echo 删除容器:`sudo docker rm $zoo_name`
  done
  if [ "$1" != "network" ];then
    echo 删除网络:`sudo docker network rm $network_name`
  fi
}
#重新启动
zookeeper_restart(){
  zookeeper_stop
  zookeeper_start
}
#查看容器状态
zookeeper_status(){
  sudo docker ps -a | grep "$name_prefix*"
}
#创建
zookeeper_create(){
  net_exists=`sudo docker network ls | grep "$network_name"`
  if [ -z "$net_exists" ];then
    echo 创建网络:` sudo docker network create --driver bridge $network_name`
  fi
  for i in $(seq 1 $count); do
    index=`expr $i + 1`
    node="server.$i=$name_prefix$i:2888:3888;2181"
    echo 节点:$node
    if [ $i -eq 1 ];then
      servers=$node
    else
      servers="$servers $node"
    fi
  done
  for i in $(seq 1 $count); do
    zoo_port=`expr $i + $client_port_start`
    echo 创建容器:`sudo docker create -i --name $name_prefix$i --hostname $name_prefix$i --restart always -p $zoo_port:2181 -e "ZOO_MY_ID=$i" -e ZOO_SERVERS="$servers" --network $network_name zookeeper`
  done
  echo 创建完成
}
#创建并启动
zookeeper_up(){
  zookeeper_create
  zookeeper_start
}

if [ ! -z "$1" ];then
  zookeeper_$1 $2
  exit 0
fi

echo "
Usage:    $0 COMMAND

可用命令:
start    启动集群
create   创建集群
stop     停止集群服务
up       创建并启动集群
down     停止并删除集群
status   查看集群容器节点信息
restart  重新启动集群"