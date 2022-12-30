# 

### 一、`etcd`是什么
> `etcd` 是一个基于 `go` 语言实现的高可用的分布式键值 `（KV）` 数据库，可以用来实现各种分布式协同服务。内部采用 `Raft` 协议作为一致性算法。



### 二、`etcd`的特点
> - 简单
> - 安全
> - 高性能
> - 可靠

- `etcd` 可以扮演两大角色
> - 持久的键值存储系统
> - 分布式系统数据一致性服务提供者

### 三、`etcd`单机部署
> 单机部署及 `web` 监控
- `docker-compose.yml`
```yml
version: '3'
networks:
  myetcd_single:
    driver: bridge

services:
  etcd:
    image: quay.io/coreos/etcd
    container_name: etcd_single
    command: etcd -name etcd1 -advertise-client-urls http://0.0.0.0:2379 -listen-client-urls http://0.0.0.0:2379 -listen-peer-urls http://0.0.0.0:2380
    ports:
      - 2379:2379
      - 2380:2380
    volumes:
      - ./data:/etcd-data
    networks:
      - myetcd_single

  etcdkeeper:
    image: deltaprojects/etcdkeeper
    container_name: etcdkeeper_single
    ports:
      - 8088:8080
    networks:
      - myetcd_single

```
- 查看集群信息
```shell
[root@r9us45kbhkhg7v58 elasitcsearch8]# curl -L http://localhost:2379/v2/members
{"members":[{"id":"5b3ea3d4b6b6fa9c","name":"etcd1","peerURLs":["http://192.168.96.3:2380"],"clientURLs":["http://0.0.0.0:2379"]}]}
[root@r9us45kbhkhg7v58 elasitcsearch8]#
[root@r9us45kbhkhg7v58 elasitcsearch8]# curl -L http://localhost:2379/v2/members
{"members":[{"id":"5b3ea3d4b6b6fa9c","name":"etcd1","peerURLs":["http://192.168.96.3:2380"],"clientURLs":["http://0.0.0.0:2379"]}]}
[root@r9us45kbhkhg7v58 elasitcsearch8]#
```

- `web`监控
> http://xxx.xx.xxx:8088/etcdkeeper/

### 四、`command`参数说明
 指定的参数名 | 作用
--- | ---
name | 节点名称
data-dir | 指定节点的数据存储目录
listen-client-urls | 对外提供服务的地址，客户端会连接到这里和etcd交互。如：http://ip:2379,http://ip:2379
listen-peer-urls | 监听URL用于与其它节点通讯
adverties-client-urls | 对外公告的该节点客户端监听地址，这个值会告诉集群中其它节点
initial-advertise-peer-urls | 该节点同伴监听地址，这个值告诉集群中其它节点
initial-cluster | 集群中所有节点的信息。格式为：node1=http://ip:2380,node2=http:ip:2380,.. 。这里的 node1 是节点的 -name 指定的名字； 后面的 ip:2380 是 -initial-advertise-peer-urls 指定的值
initial-cluster-state | 新建集群的时候，这个值为 new ；假如已经存在的集群，这个值为 existing
initial-cluster-token | 创建集群的token，这个值每个集群保持唯一。这样的话，如果你要重新创建集群，即时配置和之前一样，也会再次生成新的集群和节点 uuid；否则会导致多个集群之间的冲突，造成未知错误

### 五、`etcd`集群部署

```yml
version: '3'
networks:
  myetcd:
    driver: bridge

services:
  etcd1:
    image: quay.io/coreos/etcd
    container_name: etcd1
    command: etcd -name etcd1 -advertise-client-urls http://0.0.0.0:2379 -listen-client-urls http://0.0.0.0:2379 -listen-peer-urls http://0.0.0.0:2380 -initial-cluster-token etcd-cluster -initial-cluster "etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380" -initial-cluster-state new
    ports:
      - 12379:2379
      - 12380:2380
    volumes:
      - ./data/etcd1:/etcd-data
    networks:
      - myetcd

  etcd2:
    image: quay.io/coreos/etcd
    container_name: etcd2
    command: etcd -name etcd2 -advertise-client-urls http://0.0.0.0:2379 -listen-client-urls http://0.0.0.0:2379 -listen-peer-urls http://0.0.0.0:2380 -initial-cluster-token etcd-cluster -initial-cluster "etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380" -initial-cluster-state new
    ports:
      - 22379:2379
      - 22380:2380
    volumes:
      - ./data/etcd2:/etcd-data
    networks:
      - myetcd

  etcd3:
    image: quay.io/coreos/etcd
    container_name: etcd3
    command: etcd -name etcd3 -advertise-client-urls http://0.0.0.0:2379 -listen-client-urls http://0.0.0.0:2379 -listen-peer-urls http://0.0.0.0:2380 -initial-cluster-token etcd-cluster -initial-cluster "etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380" -initial-cluster-state new
    ports:
      - 32379:2379
      - 32380:2380
    volumes:
      - ./data/etcd3:/etcd-data
    networks:
      - myetcd

  etcdkeeper:
    image: deltaprojects/etcdkeeper
    container_name: etcdkeeper
    ports:
      - 8088:8080
    networks:
      - myetcd

```


### 六、参考文档
[通过docker安装etcd集群](https://blog.csdn.net/JineD/article/details/127290804)
[etcd](https://blog.csdn.net/mr_ximu/category_11844199.html)
[etcd从Raft原理到实](https://juejin.cn/post/7035179267918938119)
[]()