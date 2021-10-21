# Docker安装RocketMQ

### 1. 搜索镜像
```bash
[root@instance-n2fyaecn toony]# docker search rocketmq
NAME                                 DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
rocketmqinc/rocketmq                 Image repository for Apache RocketMQ            44                   
foxiswho/rocketmq                    rocketmq                                        38                   
styletang/rocketmq-console-ng        rocketmq-console-ng                             31                   
apacherocketmq/rocketmq              Docker Image for Apache RocketMQ                14                   
laoyumi/rocketmq                                                                     10                   [OK]
rocketmqinc/rocketmq-broker          Customized RocketMQ Broker Image for RocketM…   8   
```

### 2. 查看当前镜像的所有版本
> 如果要查看其它镜像，只需要替换：foxiswho/rocketmq 为其它镜像即可
```bash
[root@instance-n2fyaecn toony]# 
[root@instance-n2fyaecn toony]# curl https://registry.hub.docker.com/v1/repositories/foxiswho/rocketmq/tags | tr -d '[\[\]" ]' | tr '}' '\n' | awk -F: -v image='foxiswho/rocketmq' '{if(NR!=NF && $3 != ""){printf("%s:%s\n",image,$3)}}'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   966    0   966    0     0    188      0 --:--:--  0:00:05 --:--:--   188
foxiswho/rocketmq:4.7.0
foxiswho/rocketmq:4.8.0
foxiswho/rocketmq:base-4.3.0
foxiswho/rocketmq:base-4.3.2
foxiswho/rocketmq:base-4.4.0
foxiswho/rocketmq:base-4.5.0
foxiswho/rocketmq:base-4.5.1
foxiswho/rocketmq:base-4.5.2
foxiswho/rocketmq:base-4.6.1
```

### 3. 启动 Name Server
```bash
[root@instance-n2fyaecn toony]# docker run -d -p 9876:9876 --name rmqserver  foxiswho/rocketmq:server-4.5.1
618c24c92933f3d286e0c0dcf2a19e5cc032685b5f303175a4fd881bdd6c0b1a
[root@instance-n2fyaecn toony]# 
```

### 4. 启动 Broker
```bash
[root@instance-n2fyaecn toony]# docker run -d -p 10911:10911 -p 10909:10909 --name rmqbroker --link rmqserver:namesrv -e "NAMESRV_ADDR=namesrv:9876" -e "JAVA_OPTS=-Duser.home=/opt" -e "JAVA_OPT_EXT=-server -Xms128m -Xmx128m" foxiswho/rocketmq:broker-4.5.1
7044c223c222dcfd33d98c6bee5d66b490ef8105b28553db3c575fd032e8755a
[root@instance-n2fyaecn toony]# 
```
##### 4-1. 当前镜像默认的配置文件路径
```bash
/etc/rocketmq/broker.conf
```
##### 4-2. 通过volume挂载本机配置文件
```bash
[root@instance-n2fyaecn toony]# docker run -d -p 10911:10911 -p 10909:10909 --name rmqbroker --link rmqserver:namesrv -e "NAMESRV_ADDR=namesrv:9876" -e "JAVA_OPTS=-Duser.home=/opt" -e "JAVA_OPT_EXT=-server -Xms128m -Xmx128m" -v /conf/broker.conf:/etc/rocketmq/broker.conf foxiswho/rocketmq:broker-4.5.1
7044c223c222dcfd33d98c6bee5d66b490ef8105b28553db3c575fd032e8755a
[root@instance-n2fyaecn toony]# 
```
##### 4-3. 查看是否启动成功日志
```bash
[root@instance-n2fyaecn toony]# docker logs -f 7044c223c222
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
The broker[broker-a, 172.17.0.3:10911] boot success. serializeType=JSON and name server is namesrv:9876
```

### 5. RocketMQ Console安装
```bash
[root@instance-n2fyaecn toony]# docker run -d --name rmqconsole -p 8180:8080 --link rmqserver:namesrv -e "JAVA_OPTS=-Drocketmq.namesrv.addr=namesrv:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" -t styletang/rocketmq-console-ng
3434533dcfd33d98c6bee5d66b490ef8105b28553db3c575fd032e8755a
[root@instance-n2fyaecn toony]# 
```
##### 5-1. 访问控制台
```bash
http://182.61.41.102:8080
```


### 10. 参考文档
[Docker中RocketMQ的安装与使用](https://blog.csdn.net/fenglibing/article/details/92378090)