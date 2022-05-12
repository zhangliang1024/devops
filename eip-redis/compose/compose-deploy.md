# Docker-Compose部署Redis集群

1. 启动命令(后台启动)
   docker-compose up -d 

2. 进入容器执行，创建集群命令
   docker exec -it redis-master1 /bin/bash
   
3. 初始化Redis集群
   redis-cli --cluster create \
   182.61.41.102:6391 182.61.41.102:6392 182.61.41.102:6393 \
   182.61.41.102:6394 182.61.41.102:6395 182.61.41.102:6396 \
   --cluster-replicas 1
   
4. 创建成功后，启动
   单机启动
   redis-cli -h 182.61.41.102 -p 6391
   集群启动
   redis-cli -c -h 182.61.41.102 -p 6391
   
5. 启动成功后，查看集群节点信息
   cluster nodes
   查看集群信息
   cluster info
   
6. Springboot项目接入Redis集群
 ```yaml
spring:
  redis:
    #host: 192.168.6.139 # Redis服务器地址
    #database: 0 # Redis数据库索引（默认为0）
    #port: 6379 # Redis服务器连接端口
    password: # Redis服务器连接密码（默认为空）
    timeout: 3000ms # 连接超时时间
    lettuce:
      pool:
        max-active: 8 # 连接池最大连接数
        max-idle: 8 # 连接池最大空闲连接数
        min-idle: 0 # 连接池最小空闲连接数
        max-wait: -1ms # 连接池最大阻塞等待时间，负值表示没有限制
    cluster:
      nodes:
        - 192.168.6.139:6391
        - 192.168.6.139:6392
        - 192.168.6.139:6393
        - 192.168.6.139:6394
        - 192.168.6.139:6395
        - 192.168.6.139:6396
```   

7. 参考文档
[Docker环境下秒建Redis集群，连SpringBoot也整上了](http://www.macrozheng.com/#/reference/redis_cluster)