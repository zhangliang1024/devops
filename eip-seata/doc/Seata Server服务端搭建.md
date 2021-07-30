# Seata Server服务端搭建

## 一、官网地址

[Seata 文档](http://seata.io/zh-cn/index.html)

[Seata github](https://github.com/seata/seata)

[Seata releases](https://github.com/seata/seata/releases)



## 二、Seata Server 下载

> 这里地址为 `1.3.0版本`
>
> [seata-server-1.3.0](https://github.com/seata/seata/releases/download/v1.3.0/seata-server-1.3.0.zip)

- Linux

```bash
wget https://github.com/seata/seata/releases/download/v1.3.0/seata-server-1.3.0.zip
```



## 三、修改配置文件

> 配置文件主要有：`registry.conf` `file.conf`
>
> - `registry.conf` : Seata 服务注册中心地址，配置中心地址
>
> - `file.conf`  :  当配置中心使用 `file`时，此配置文件生效。配置`store`存储配置
>
>   这里我们使用`eureka`做为注册中心，`Apollo`做为配置中心

#### `registry.conf`

```conf
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "eureka"
  # 配置eureka地址
  eureka {
    serviceUrl = "http://10.0.17.92:9001/eureka"
    application = "seata-server"
    weight = "1"
  }
  ...
  file {
    name = "file.conf"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  #type = "file"
  type = "apollo"
  # 配置中心配置apollo地址和namespace
  apollo {
    appId = "seata-server"
    apolloMeta = "http://10.0.17.92:9083"
    namespace = "application"
  }
  file {
    name = "file.conf"
  }
}
```

#### `file.conf`

```conf
## transaction log store, only used in seata-server
store {
  ## store mode: file、db、redis
  mode = "db"

  ## file store property
  file {
    ## store location dir
    dir = "sessionStore"
    # branch session size , if exceeded first try compress lockkey, still exceeded throws exceptions
    maxBranchSessionSize = 16384
    # globe session size , if exceeded throws exceptions
    maxGlobalSessionSize = 512
    # file buffer size , if exceeded allocate new buffer
    fileWriteBufferCacheSize = 16384
    # when recover batch read size
    sessionReloadReadSize = 100
    # async, sync
    flushDiskMode = async
  }

  ## database store property
  db {
    ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp)/HikariDataSource(hikari) etc.
    datasource = "druid"
    ## mysql/oracle/postgresql/h2/oceanbase etc.
    dbType = "mysql"
    driverClassName = "com.mysql.cj.jdbc.Driver"
    url = "jdbc:mysql://10.0.17.122:3306/seata"
    user = "root"
    password = "Pdhn^456"
    minConn = 5
    maxConn = 30
    globalTable = "global_table"
    branchTable = "branch_table"
    lockTable = "lock_table"
    queryLimit = 100
    maxWait = 5000
  }

  ## redis store property
  redis {
    host = "127.0.0.1"
    port = "6379"
    password = ""
    database = "0"
    minConn = 1
    maxConn = 10
    queryLimit = 100
  }
}
```

#### Apollo配置Server配置

> 主要修改：数据库地址 用户名  密码等
>
> - 注意：mysql 版本问题  1.3.0后，Seata使用mysql 8.0版本

```properties
transport.type = TCP
transport.server = NIO
transport.heartbeat = true
transport.enableClientBatchSendRequest = false
transport.threadFactory.bossThreadPrefix = NettyBoss
transport.threadFactory.workerThreadPrefix = NettyServerNIOWorker
transport.threadFactory.serverExecutorThreadPrefix = NettyServerBizHandler
transport.threadFactory.shareBossWorker = false
transport.threadFactory.clientSelectorThreadPrefix = NettyClientSelector
transport.threadFactory.clientSelectorThreadSize = 1
transport.threadFactory.clientWorkerThreadPrefix = NettyClientWorkerThread
transport.threadFactory.bossThreadSize = 1
transport.threadFactory.workerThreadSize = default
transport.shutdown.wait = 3
transport.serialization = seata
transport.compressor = none

store.mode = db
store.db.datasource = druid
store.db.dbType = mysql
store.db.driverClassName = com.mysql.jdbc.Driver
store.db.url = jdbc:mysql://10.0.17.122:3306/seata?useUnicode=true
store.db.user = root
store.db.password = xxxx
store.db.minConn = 5
store.db.maxConn = 30
store.db.globalTable = global_table
store.db.branchTable = branch_table
store.db.queryLimit = 100
store.db.lockTable = lock_table
store.db.maxWait = 5000

server.recovery.committingRetryPeriod = 1000
server.recovery.asynCommittingRetryPeriod = 1000
server.recovery.rollbackingRetryPeriod = 1000
server.recovery.timeoutRetryPeriod = 1000
server.maxCommitRetryTimeout = -1
server.maxRollbackRetryTimeout = -1
server.rollbackRetryTimeoutUnlockEnable = false

metrics.enabled = false
metrics.registryType = compact
```

#### 初始化数据库

> - `global_table`  维护全局事务
> - `branch_table`  维护分支事务
> - `lock_table`  维护全局锁

```sql
-- the table to store GlobalSession data
drop table if exists `global_table`;
create table `global_table` (
  `xid` varchar(128)  not null,
  `transaction_id` bigint,
  `status` tinyint not null,
  `application_id` varchar(32),
  `transaction_service_group` varchar(32),
  `transaction_name` varchar(128),
  `timeout` int,
  `begin_time` bigint,
  `application_data` varchar(2000),
  `gmt_create` datetime,
  `gmt_modified` datetime,
  primary key (`xid`),
  key `idx_gmt_modified_status` (`gmt_modified`, `status`),
  key `idx_transaction_id` (`transaction_id`)
);

-- the table to store BranchSession data
drop table if exists `branch_table`;
create table `branch_table` (
  `branch_id` bigint not null,
  `xid` varchar(128) not null,
  `transaction_id` bigint ,
  `resource_group_id` varchar(32),
  `resource_id` varchar(256) ,
  `lock_key` varchar(128) ,
  `branch_type` varchar(8) ,
  `status` tinyint,
  `client_id` varchar(64),
  `application_data` varchar(2000),
  `gmt_create` datetime,
  `gmt_modified` datetime,
  primary key (`branch_id`),
  key `idx_xid` (`xid`)
);

-- the table to store lock data
drop table if exists `lock_table`;
create table `lock_table` (
  `row_key` varchar(128) not null,
  `xid` varchar(96),
  `transaction_id` long ,
  `branch_id` long,
  `resource_id` varchar(256) ,
  `table_name` varchar(32) ,
  `pk` varchar(36) ,
  `gmt_create` datetime ,
  `gmt_modified` datetime,
  primary key(`row_key`)
);
```



## 四、`Seata-Server`启动

> - 先保证配置`eureka` `apollo`配置，启动注册中心和配置中心

- `Apollo` 配置

![image-20210329220159448](D:\文档\项目实战\seata\seata在apollo的配置.png)

- 进入到： `seata/bin`目录

```bash
nohup sh seata-server.sh -h 10.0.17.92 -p 8091 &
```

- `Eureka`

![](D:\文档\项目实战\seata\seata注册到注册中心.png)



## 五、`Docker`启动 `Seata server`



### 1. 拉取 `seata-server`镜像

```bash
docker pull docker.io/seataio/seata-server:1.3.0
```

### 2. 修改配置文件`registry.conf`

> - 配置 Apollo

 ```conf
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "eureka"
  loadBalance = "RandomLoadBalance"
  loadBalanceVirtualNodes = 10

  eureka {
    serviceUrl = "http://10.0.17.92:9001/eureka"
    application = "seata-server"
    weight = "1"
  }

  file {
    name = "file.conf"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "apollo"

  apollo {
    appId = "seata-server"
    apolloMeta = "http://10.0.17.92:9083"
    namespace = "application"
  }
 
  file {
    name = "file.conf"
  }
}
 ```

### 3. 启动脚本 

> start.sh

```shell
#!/bin/bash
 
docker stop seata-server;
docker container rm seata-server;
 
docker run --name seata-server -it -d  -p 8091:8091 \
-e SEATA_CONFIG_NAME=file:/root/seata/config/registry \
-e SEATA_IP=10.0.17.92 \
-v /opt/seata/config:/root/seata/config \
- v /opt/seata/config/libs/mysql-connector-java-8.0.21.jar:/root/seata/config/libs/mysql-connector-java-8.0.21.jar \
--net=bridge --restart=always docker.io/seataio/seata-server:1.3.0
```



## 六、 `Docker Compose` 启动 `Seata server`

> - 注意数据库版本问题，1.3.0版本后  mysql驱动为 8.0版本
>
> ​      - 在config目录中，配置`mysql-connector-java-8.0.21.jar`驱动
>
> - `Apollo`数据库驱动 `cj`，连接地址加 `characterEncoding=utf-8&serverTimezone=UTC`
>
> ```properties
> store.db.driverClassName = com.mysql.cj.jdbc.Driver
> store.db.url = jdbc:mysql://10.0.17.122:3306/seata?useUnicode=true&characterEncoding=utf-8&serverTimezone=UTC
> ```
>
> - 启动容器
>
> ```bash
> docker-compose up -d 
> ```

### 1. `docker-compose.yml`配置文件

```yaml
version: "3"
services:
  seata-server:
    image: seataio/seata-server:1.3.0
    container_name: seata-server
    hostname: seata-server
    ports:
      - "8091:8091"
    volumes:
      - "/opt/seata/config:/root/seata/config"
      - "/opt/seata/config/libs/mysql-connector-java-8.0.21.jar:/root/seata/config/libs/mysql-connector-java-8.0.21.jar"
    environment:
      - SEATA_CONFIG_NAME=file:/root/seata/config/registry
      - SEATA_IP=10.0.17.92
      - SEATA_PORT=8091
       - STORE_MODE=db
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.3'
          memory: 300M  
```

### 2. `registry.conf`

```conf
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "eureka"
  loadBalance = "RandomLoadBalance"
  loadBalanceVirtualNodes = 10

  eureka {
    serviceUrl = "http://10.0.17.92:9001/eureka"
    application = "seata-server"
    weight = "1"
  }

  file {
    name = "file.conf"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "apollo"

  apollo {
    appId = "seata-server"
    apolloMeta = "http://10.0.17.92:9083"
    namespace = "application"
  }
 
  file {
    name = "file:/root/seata/config/file.conf"
  }
}
```

### 3. 异常 `database `

> com.mysql.jdbc.exceptions.jdbc4.MySQLNonTransientConnectionException: Could not create connection to database server

```bash
15:09:54.010 ERROR --- [ionPool-Create-1072506992] com.alibaba.druid.pool.DruidDataSource   : create connection SQLException, url: jdbc:mysql://10.0.17.122:3306/seata?useUnicode=true, errorCode 0, state 08001
==>
com.mysql.jdbc.exceptions.jdbc4.MySQLNonTransientConnectionException: Could not create connection to database server.
        at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
        at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
        at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
        at com.mysql.jdbc.Util.handleNewInstance(Util.java:389)
        at com.mysql.jdbc.Util.getInstance(Util.java:372)
```

### 4. 进入seata server 容器

```bash
[root@lipei92 seata]# docker ps|grep seata
55af30b183b7        seataio/seata-server:1.4.1          "java -Djava.secur..."   4 minutes ago       Up 8 seconds          0.0.0.0:8091->8091/tcp                                             seata-server
[root@lipei92 seata]# docker exec -it 55af30b183b7 sh
/seata-server # pwd
/seata-server
```







## 九、参考文档

- `Docker-compose`主要参考

[使用docker安装seata-server，mysql8引擎，nacos作为注册和配置中心](https://www.jianshu.com/p/d7c87936c99f)





- `Docker` 主要参考文档

[docker快速部署一个seata-server+向nacos推送配置](https://blog.csdn.net/u014618954/article/details/105976266/)