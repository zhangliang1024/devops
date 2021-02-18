### 1、拉取 Redis 镜像
> 基于 Redis：5.0.5 版本，执行如下指令：
```bash
docker pull redis:5.0.5
```

### 2、创建 6 个 Redis 容器
> 创建 6 个Redis 容器：
```text
redis-node1：6379
redis-node2：6380
redis-node3：6381
redis-node4：6382
redis-node5：6383
redis-node6：6384

部分参数解释：

--cluster-enabled：是否启动集群，选值：yes 、no
--cluster-config-file 配置文件.conf ：指定节点信息，自动生成
--cluster-node-timeout 毫秒值： 配置节点连接超时时间
--appendonly：是否开启持久化，选值：yes、no

```
> 执行命令如下：
```bash
docker create --name redis-node1 --net host -v /data/redis-data/node1:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-1.conf --port 6379

docker create --name redis-node2 --net host -v /data/redis-data/node2:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-2.conf --port 6380

docker create --name redis-node3 --net host -v /data/redis-data/node3:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-3.conf --port 6381

docker create --name redis-node4 --net host -v /data/redis-data/node4:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-4.conf --port 6382

docker create --name redis-node5 --net host -v /data/redis-data/node5:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-5.conf --port 6383

docker create --name redis-node6 --net host -v /data/redis-data/node6:/data redis:5.0.5 --cluster-enabled yes --cluster-config-file nodes-node-6.conf --port 6384

```

### 3、启动 Redis 容器
执行命令如下：
```bash
docker start redis-node1 redis-node2 redis-node3 redis-node4 redis-node5 redis-node6
```

### 4、组建 Redis 集群
> 进入任意一个 Redis 实例,这里以 redis-node1 实例为例:
```bash
docker exec -it redis-node1 /bin/bash
```
> 执行组件集群的命令,组建集群,10.211.55.4为当前物理机的ip地址:
```bash
redis-cli --cluster create 10.211.55.4:6379 10.211.55.4:6380 10.211.55.4:6381 10.211.55.4:6382 10.211.55.4:6383 10.211.55.4:6384 --cluster-replicas 1
```

> 创建成功后，通过 redis-cli 查看一下集群节点信息：
```bash
root@CentOS7:/data# redis-cli
127.0.0.1:6379> cluster nodes
a48a4fdc0d36a269fdbcd8c89306edb66c9d2ccf 182.61.41.102:6382@16382 slave 9b8950640ee13b7ffdf4dc06ab1225ec1f304be2 0 1613612251877 4 connected
8fecf5ee9c3b980c7857333d27a48779e7dd4670 182.61.41.102:6381@16381 master - 0 1613612251000 3 connected 10923-16383
a050b24b0f1472fceecd60c10048bbd6b5b137df 182.61.41.102:6384@16384 slave 3ea465f6ac2b5ec836c663f23b3d7f0fa7eba97a 0 1613612248000 6 connected
9b8950640ee13b7ffdf4dc06ab1225ec1f304be2 182.61.41.102:6380@16380 master - 0 1613612249847 2 connected 5461-10922
79fece36e9881858cbf4ae0e493a7780b70f7501 182.61.41.102:6383@16383 slave 8fecf5ee9c3b980c7857333d27a48779e7dd4670 0 1613612250000 5 connected
3ea465f6ac2b5ec836c663f23b3d7f0fa7eba97a 172.16.16.4:6379@16379 myself,master - 0 1613612249000 1 connected 0-5460
127.0.0.1:6379> 
```


### 5、关于Redis集群搭建
```text
我们再回到创建集群的命令上：
  redis-cli --cluster create 10.211.55.4:6379~6384 --cluster-replicas 1
  --cluster-replicas 1，参数后面的数字表示的是主从比例，比如这里的 1 表示的是主从比例是 1:1，什么概念呢？

也就是 1 个主节点对应几个从节点，现有 6 个实例，所以主从分配就是 3 个 master 主节点，3 个 slave 从节点。
主节点最少3个，3个才能保证集群的健壮性。

```


### 参考文章

[基于Docker搭建Redis集群（主从集群）](https://www.cnblogs.com/niceyoo/p/14118146.html)

