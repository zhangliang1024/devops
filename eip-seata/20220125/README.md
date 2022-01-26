# 分布式事务`Seata`
### 1.快速部署
- 创建数据库
> `seata`
```sql
------------ The script used when storeMode is 'db' ------------

-- the table to store GlobalSession data
CREATE TABLE IF NOT EXISTS `global_table`
(
    `xid`                       VARCHAR(128) NOT NULL,
    `transaction_id`            BIGINT,
    `status`                    TINYINT      NOT NULL,
    `application_id`            VARCHAR(32),
    `transaction_service_group` VARCHAR(32),
    `transaction_name`          VARCHAR(128),
    `timeout`                   INT,
    `begin_time`                BIGINT,
    `application_data`          VARCHAR(2000),
    `gmt_create`                DATETIME,
    `gmt_modified`              DATETIME,
    PRIMARY KEY (`xid`),
    KEY `idx_gmt_modified_status` (`gmt_modified`, `status`),
    KEY `idx_transaction_id` (`transaction_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- the table to store BranchSession data
CREATE TABLE IF NOT EXISTS `branch_table`
(
    `branch_id`         BIGINT       NOT NULL,
    `xid`               VARCHAR(128) NOT NULL,
    `transaction_id`    BIGINT,
    `resource_group_id` VARCHAR(32),
    `resource_id`       VARCHAR(256),
    `branch_type`       VARCHAR(8),
    `status`            TINYINT,
    `client_id`         VARCHAR(64),
    `application_data`  VARCHAR(2000),
    `gmt_create`        DATETIME(6),
    `gmt_modified`      DATETIME(6),
    PRIMARY KEY (`branch_id`),
    KEY `idx_xid` (`xid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- the table to store lock data
CREATE TABLE IF NOT EXISTS `lock_table`
(
    `row_key`        VARCHAR(128) NOT NULL,
    `xid`            VARCHAR(128),
    `transaction_id` BIGINT,
    `branch_id`      BIGINT       NOT NULL,
    `resource_id`    VARCHAR(256),
    `table_name`     VARCHAR(32),
    `pk`             VARCHAR(36),
    `gmt_create`     DATETIME,
    `gmt_modified`   DATETIME,
    PRIMARY KEY (`row_key`),
    KEY `idx_branch_id` (`branch_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `distributed_lock`
(
    `lock_key`       CHAR(20) NOT NULL,
    `lock_value`     VARCHAR(20) NOT NULL,
    `expire`         BIGINT,
    primary key (`lock_key`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('AsyncCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryCommitting', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('RetryRollbacking', ' ', 0);
INSERT INTO `distributed_lock` (lock_key, lock_value, expire) VALUES ('TxTimeoutCheck', ' ', 0);
```

- 部署文件`docker-compose.yaml`
```bash
version: "3"
services:
  seata-server:
    image: seataio/seata-server:1.4.2
    container_name: seata-server
    ports:
    - "8091:8091"
    volumes:
    - ${PWD}/conf/registry.conf:/seata-server/resources/registry.conf
    - ${PWD}/logs:/root/logs
    environment:
    - SERVER_NODE=1
    - SEATA_IP=10.0.17.92
    - SEATA_PORT=8091
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.3'
          memory: 300M
```

- `registry.conf`
> 注册中心、配置中心 `Nacos`配置
```bash
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  # 指定注册中心为nacos
  type = "nacos"

  nacos {
    application = "seata-server"
  	#需替换成自己ip,得是本机ip地址不能是localhost
    serverAddr = "http://139.198.16.11:8848"
    namespace = ""
    group = "SEATA_GROUP"
    cluster = "default"
    username="nacos"
    password="nacos"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "nacos"

 nacos {
    #需替换成自己ip，得是本机ip地址不能是localhost
    serverAddr = "http://139.198.16.11:8848"
    namespace = ""
    group = "SEATA_GROUP"
    username="nacos"
    password="nacos"
    dataId = "seata-server.properties"
  }
}
```

- `seata-server.properties`
> 修改数据库配置
```properties
transport.type=TCP
transport.server=NIO
transport.heartbeat=true
transport.enableClientBatchSendRequest=true
transport.threadFactory.bossThreadPrefix=NettyBoss
transport.threadFactory.workerThreadPrefix=NettyServerNIOWorker
transport.threadFactory.serverExecutorThreadPrefix=NettyServerBizHandler
transport.threadFactory.shareBossWorker=false
transport.threadFactory.clientSelectorThreadPrefix=NettyClientSelector
transport.threadFactory.clientSelectorThreadSize=1
transport.threadFactory.clientWorkerThreadPrefix=NettyClientWorkerThread
transport.threadFactory.bossThreadSize=1
transport.threadFactory.workerThreadSize=default
transport.shutdown.wait=3
transport.serialization=seata
transport.compressor=none
# server
server.recovery.committingRetryPeriod=1000
server.recovery.asynCommittingRetryPeriod=1000
server.recovery.rollbackingRetryPeriod=1000
server.recovery.timeoutRetryPeriod=1000
server.undo.logSaveDays=7
server.undo.logDeletePeriod=86400000
server.maxCommitRetryTimeout=-1
server.maxRollbackRetryTimeout=-1
server.rollbackRetryTimeoutUnlockEnable=false
server.distributedLockExpireTime=10000
# store
#model改为db
store.mode=db
store.lock.mode=file
store.session.mode=file
# store.publicKey=""
store.file.dir=file_store/data
store.file.maxBranchSessionSize=16384
store.file.maxGlobalSessionSize=512
store.file.fileWriteBufferCacheSize=16384
store.file.flushDiskMode=async
store.file.sessionReloadReadSize=100
store.db.datasource=druid
store.db.dbType=mysql
store.db.driverClassName=com.mysql.jdbc.Driver
# 改为上面创建的seata服务数据库
store.db.url=jdbc:mysql://139.198.16.11:3306/seata?useUnicode=true&rewriteBatchedStatements=true
# 改为自己的数据库用户名
store.db.user=root
# 改为自己的数据库密码
store.db.password=123456
store.db.minConn=5
store.db.maxConn=30
store.db.globalTable=global_table
store.db.branchTable=branch_table
store.db.distributedLockTable=distributed_lock
store.db.queryLimit=100
store.db.lockTable=lock_table
store.db.maxWait=5000
store.redis.mode=single
store.redis.single.host=127.0.0.1
store.redis.single.port=6379
# store.redis.sentinel.masterName=""
# store.redis.sentinel.sentinelHosts=""
store.redis.maxConn=10
store.redis.minConn=1
store.redis.maxTotal=100
store.redis.database=0
# store.redis.password=""
store.redis.queryLimit=100
# log
log.exceptionRate=100
# metrics
metrics.enabled=false
metrics.registryType=compact
metrics.exporterList=prometheus
metrics.exporterPrometheusPort=9898
# service
# 自己命名一个vgroupMapping
service.vgroupMapping.test-tx-group=default
service.default.grouplist=139.198.16.11:8091
service.enableDegrade=false
service.disableGlobalTransaction=false
# client
client.rm.asyncCommitBufferLimit=10000
client.rm.lock.retryInterval=10
client.rm.lock.retryTimes=30
client.rm.lock.retryPolicyBranchRollbackOnConflict=true
client.rm.reportRetryCount=5
client.rm.tableMetaCheckEnable=false
client.rm.tableMetaCheckerInterval=60000
client.rm.sqlParserType=druid
client.rm.reportSuccessEnable=false
client.rm.sagaBranchRegisterEnable=false
client.rm.tccActionInterceptorOrder=-2147482648
client.tm.commitRetryCount=5
client.tm.rollbackRetryCount=5
client.tm.defaultGlobalTransactionTimeout=60000
client.tm.degradeCheck=false
client.tm.degradeCheckAllowTimes=10
client.tm.degradeCheckPeriod=2000
client.tm.interceptorOrder=-2147482648
client.undo.dataValidation=true
client.undo.logSerialization=jackson
client.undo.onlyCareUpdateColumns=true
client.undo.logTable=undo_log
client.undo.compress.enable=true
client.undo.compress.type=zip
client.undo.compress.threshold=64k
```

- 执行启动
```bash
sh build.sh
```

### 5-2.项目集成
- 初始化`SQL`
> 涉及到业务库都要新建：undo_log表
```sql
CREATE TABLE IF NOT EXISTS `undo_log`
(
    `branch_id`     BIGINT(20)   NOT NULL COMMENT 'branch transaction id',
    `xid`           VARCHAR(100) NOT NULL COMMENT 'global transaction id',
    `context`       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    `rollback_info` LONGBLOB     NOT NULL COMMENT 'rollback info',
    `log_status`    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    `log_created`   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    `log_modified`  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY `ux_undo_log` (`xid`, `branch_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8 COMMENT ='AT transaction mode undo table';
```

- `pom.xml`依赖
> 依赖 ，目前和`Seata Server`服务端保持版本一致：1.3.0
```xml
<!--SpringCloud alibaba seata-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-seata</artifactId>
    <exclusions>
        <!-- 要与seata服务端版本一直,所以把自带的替换掉 -->
        <exclusion>
            <groupId>io.seata</groupId>
            <artifactId>seata-spring-boot-starter</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>io.seata</groupId>
    <artifactId>seata-spring-boot-starter</artifactId>
    <version>1.4.2</version>
</dependency>
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```

- 配置文件`application.yml`
```yaml
seata:
  enabled: true
  enable-auto-data-source-proxy: true #是否开启数据源自动代理,默认为true
  tx-service-group: test-tx-group  #要与配置文件中的vgroupMapping一致
  registry:  #registry根据seata服务端的registry配置
    type: nacos 
    nacos:
      application: seata-server #配置自己的seata服务
      server-addr: 139.198.16.11:8848 #根据自己的seata服务配置
      username: nacos #根据自己的seata服务配置
      password: nacos #根据自己的seata服务配置
      namespace: #根据自己的seata服务配置
      cluster: default # 配置自己的seata服务cluster, 默认为 default
      group: SEATA_GROUP #根据自己的seata服务配置
  config:
    type: nacos
    nacos:
      server-addr: 139.198.16.11:8848 #配置自己的nacos地址
      group: SEATA_GROUP #配置自己的dev
      username: nacos #配置自己的username
      password: nacos #配置自己的password
      namespace: #配置自己的namespace
      dataId: seata-server.properties  #配置自己的dataId,由于搭建服务端时把客户端的配置也写在了seataServer.properties,所以这里用了和服务端一样的配置文件,实际客户端和服务端的配置文件分离出来更好

```

- 代码使用
> `@GlobalTransactional`可以自定义名称和超时时间，默认超时时间：60秒
```java
@GlobalTransactional(timeoutMills = 60000,rollbackFor = Exception.class)
public Result submitById(ReportDispatchingCommand command, UserLoginDTO userLoginDTO){
    //业务逻辑
}
```


## 参考文档
* [Seata1.4.2+Nacos搭建使用](https://blog.csdn.net/ww_run/article/details/120099870)
* [docker安装seata基于nacos的集群](https://www.jianshu.com/p/44a8f1b945de)
* [docker-compose安装nacos、seata、sentinel](https://blog.csdn.net/zhang18636202912/article/details/114228293)