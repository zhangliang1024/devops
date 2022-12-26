

### `Nacos`集群部署
- 版本
```properties
Nacos: nacos/nacos-server:latest
Mysql: nacos/nacos-mysql:5.7
```

### 启动
```shell
[root@r9us45kbhkhg7v58 nacos]# cd /opt/nacos
[root@r9us45kbhkhg7v58 nacos]# ls
build.sh  docker-compose.yml
[root@r9us45kbhkhg7v58 nacos]# 
[root@r9us45kbhkhg7v58 nacos]# docker-compose up -d
[+] Running 5/5
 ⠿ Network nacos_skywalking_networks  Created                                                                                                                                 0.1s
 ⠿ Container nacos-sql                Started                                                                                                                                 0.6s
 ⠿ Container nacos03                  Started                                                                                                                                 1.7s
 ⠿ Container nacos01                  Started                                                                                                                                 1.7s
 ⠿ Container nacos02                  Started                                                                                                                                 1.7s
[root@r9us45kbhkhg7v58 nacos]# docker logs -f nacos01
```

### 参考文档
[Nacos集群部署](https://blog.csdn.net/wb4927598/article/details/119192345)

[Nacos高可用集群搭建 ](https://www.cnblogs.com/wwjj4811/p/14610307.html)