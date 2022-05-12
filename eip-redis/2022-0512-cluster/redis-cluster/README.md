# docker-compose搭建redis-cluster集群

### 一、创建集群
```bash
docker exec -it redis-1 bash
#进入容器后运行:
redis-cli
#如果设置了验证密码: (本人上面redis.conf中设置的验证密码是123456)
auth 123321
#创建集群   命令里的1代表为每个创建的主服务器节点创建一个从服务器节点
redis-cli -a 123321 --cluster create --cluster-replicas 1 \
182.42.116.245:6379 \
182.42.116.245:6380 \
182.42.116.245:6381 \
182.42.116.245:6382 \
182.42.116.245:6383 \
182.42.116.245:6384

```

### 二、集群验证
```bash
# (1)建立连接
redis-cli -a 123321 -c -h 182.42.116.245 -p 6379

# (2)进行验证： cluster info（查看集群信息）、cluster nodes（查看节点列表）
cluster info

# (3)进行数据操作验证
```

### 三、参考文档
* [docker-compose搭建redis-cluster集群](https://www.jianshu.com/p/b951bf34cee5)
* [使用DockerCompose搭建Redis集群](http://t.zoukankan.com/wugang-p-14491468.html)


### 说明
> 使用`docker-compose`方式时，如果未指定网络，会以`文件夹_default`的规则自动创建一网络。此次创建的所有容器都会加入该网络，其中的容器可以互相访问
> - `docker network ls` 查看