# docker部署redis

### 一、快速部署
```bash
docker run -d --name redis \
    --restart always \
    -p 6379:6379 \
    -v /home/redis/data:/data \
    redis redis-server /etc/redis/redis.conf \
    --requirepass "123456" --appendonly yes
```

### 二、部署及问题处理
> `docker`启动报可用`IPv4 addresss`不足
```bash
[root@k8s-cce-01-89424 redis]# docker run -d --name redis --restart always -p 6379:6379 -v /home/redis:/etc/redis -v /home/redis/data:/data redis redis-server /etc/redis/redis.conf --requirepass "123456" --appendonly yes
45adcf77ffd9b62d36c575dfd6a71f7583227c171c30f7c63fdf7642dceaf8cf
docker: Error response from daemon: no available IPv4 addresses on this network's address pools: bridge (828f0db5444891b1d21f430cc077230afa2361ec56a6d40194610d943a7b741e).
```
#### 1.新建网络
```bash
docker network create --subnet 172.18.0.1/16 new_network
```
#### 2.使用自定义网络
> `--network own_network`
```bash
[root@k8s-cce-01-89424 redis]# docker run -d --name redis --restart always -p 6379:6379 --network own_network -v /home/redis:/etc/redis -v /home/redis/data:/data redis redis-server /etc/redis/redis.conf --requirepass "123456" --appendonly yes
8185d890a85b5262acd7a060274f60ed551a036fe80dc5e16d4fbe1fe5b2c34a
[root@k8s-cce-01-89424 redis]# 
```
#### 3.`docker-compose`使用自定义网络
```bash
docker run -d \
    --name redis \
    --restart=always \
    --network own_network\
    -p 6379:6379 \
    -v /home/redis/redis.conf:/etc/redis/redis.conf \
    -v /home/redis/data:/data \
    redis redis-server /etc/redis/redis.conf
    --requirepass "123456" 
```


### 三、访问`redis-cli`
```bash
[root@cm3gy24x0wravmtj redis]# docker exec -it redis redis-cli
127.0.0.1:6379> 
127.0.0.1:6379> 
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
(empty array)
127.0.0.1:6379> 
```

### 五、参考文档
[docker IPv4 address pool 不足问题](https://www.jianshu.com/p/e86aaf5d78a6)
[docker 运行redis完整版](https://blog.csdn.net/wzwwzwwww/article/details/113588714)