# Seata分布式事务微服务接入



## 一、初始化SQL

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



## 二、项目配置

> 依赖 ，目前和`Seata Server`服务端保持版本一致：1.3.0

```xml
<!--SpringCloud alibaba seata-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-seata</artifactId>
    <version>2.2.0.RELEASE</version>
    <exclusions>
        <exclusion>
            <groupId>io.seata</groupId>
            <artifactId>seata-spring-boot-starter</artifactId>
        </exclusion>
        <exclusion>
            <groupId>io.seata</groupId>
            <artifactId>seata-all</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>io.seata</groupId>
    <artifactId>seata-spring-boot-starter</artifactId>
    <version>1.3.0</version>
</dependency>
<!--<dependency>-->
    <!--<groupId>io.seata</groupId>-->
    <!--<artifactId>seata-all</artifactId>-->
    <!--<version>1.3.0</version>-->
<!--</dependency>-->
```



> `application	`配置

```yaml
seata:
  # 开启Springboot自动装配 默认true
  enabled: true
  # 开启数据源自动代理 默认true
  enable-auto-data-source-proxy: true
  # 
  application-id: ${spring.application.name}
  # 事务组(可以每个应用独立取名,也可以使用相同的名字,注意跟配置文件保持一致)
  tx-service-group: ${spring.application.name}
  # 配置中心
  config:
    type: apollo
    apollo:
      app-id: ${spring.application.name}
      apollo-meta: http://10.0.17.92:9083
      namespace: seata
  # 注册中心
  registry:
    type: eureka
    eureka:
      weight: 1
      application: seata-server
      service-url: http://10.0.17.92:9001/eureka/
```

> `Apollo ` `seata`命名空间配置

```properties
# transport配置
transport.type = TCP
transport.server = NIO
transport.heartbeat = true
# 客户端事务消息请求合并发送 默认true
transport.enableClientBatchSendRequest = true
transport.compressor = none
transport.shutdown.wait = 3
transport.serialization = seata
transport.threadFactory.bossThreadPrefix = NettyBoss
transport.threadFactory.workerThreadPrefix = NettyServerNIOWorker
transport.threadFactory.serverExecutorThread-prefix = NettyServerBizHandler
transport.threadFactory.shareBossWorker = false
transport.threadFactory.clientSelectorThreadPrefix = NettyClientSelector
transport.threadFactory.clientSelectorThreadSize = 1
transport.threadFactory.clientWorkerThreadPrefix = NettyClientWorkerThread
transport.threadFactory.bossThreadSize = 1
transport.threadFactory.workerThreadSize = default

# client配置
# 异步提交缓存队列长度(默认10000)
client.rm.asyncCommitBufferLimit = 10000
# 一阶段结果上报TC重试次数(默认5)
client.rm.reportRetryCount = 5
# 自动刷新缓存中的表结构(默认false)
client.rm.tableMetaCheckEnable = false
# 是否上报一阶段成功(默认false),true用于保持分支事务生命周期完整
client.rm.reportSuccessEnable = false
# 校验或占用全局锁重试间隔(默认10ms)
client.rm.lock.retryInterval = 10
# 校验或占用全局锁重试次数(默认30)
client.rm.lock.retryTimes = 30
# 分支事务与其它全局事务回滚事务冲突时策略(优先释放本地锁让回滚)
client.rm.lock.retryPolicyBranchRollbackOnConflict = true
# 一阶段全局回滚上报TC重试次数(默认1次，建议大于1)
client.tm.rollbackRetryCount = 3
# 一阶段全局提交上报TC重试次数(默认1次，建议大于1)
client.tm.commitRetryCount = 3
# undo序列化方式(默认jackson)
client.undo.logSerialization = jackson
# 自定义undo_log表明(默认undo_log)
client.undo.logTable = undo_log
# 二阶段回滚镜像校验(默认true开启)
client.undo.dataValidation = false
# 日志异常输出概率(默认100)
client.log.exceptionRate = 100

# service配置
# seata-server服务端地址
service.default.grouplist = 10.0.17.92:8091
# 各自项目需配置自己的 service.vgroupMapping.事务组 , seata-server为服务端事务组
service.vgroupMapping.claim-workflow = seata-server
# 开启降级，业务连续出错则不使用事务。默认false
service.enableDegrade = false
# 禁用全局事务(默认false)
service.disableGlobalTransaction = false
```



## 三、手动注入数据源

> `Seata` 1.3.0版本后，已经实现自动数据代理注入。
>
> - 参数：seata.enable-auto-data-source-proxy=true  ,默认为true

```java
@Configuration
public class DataSourceProxyConfig {

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource druidDataSource(){
        return new DruidDataSource();
    }
}
```

```java
import com.alibaba.druid.pool.DruidDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class DataSourceProxyConfig {

    //@Value("${mybatis-plus.mapper-locations}")
    //private String mapperLocations;

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource druidDataSource(){
        return new DruidDataSource();
    }

    //@Primary
    //@Bean
    //public DataSourceProxy dataSourceProxy(DataSource dataSource) {
    //    return new DataSourceProxy(dataSource);
    //}

    //代理mybaits-plus
    //@Bean
    //public MybatisSqlSessionFactoryBean sqlSessionFactoryBean(DataSource dataSourceProxy) throws Exception {
    //    MybatisSqlSessionFactoryBean sqlSessionFactoryBean = new MybatisSqlSessionFactoryBean();
    //    sqlSessionFactoryBean.setDataSource(dataSourceProxy);
    //    sqlSessionFactoryBean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(mapperLocations));
    //    sqlSessionFactoryBean.setTransactionFactory(new SpringManagedTransactionFactory());
    //    return sqlSessionFactoryBean;
    //}

    //代理mybatis / mybatis-config
    //@Bean
    //public SqlSessionFactory sqlSessionFactoryBean(DataSourceProxy dataSourceProxy) throws Exception {
    //    SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
    //    sqlSessionFactoryBean.setDataSource(dataSourceProxy);
    //    sqlSessionFactoryBean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(mapperLocations));
    //    sqlSessionFactoryBean.setTransactionFactory(new SpringManagedTransactionFactory());
    //    return sqlSessionFactoryBean.getObject();
    //}

}
```





## 四、事务使用

> `@GlobalTransactional`可以自定义名称和超时时间，默认超时时间：60秒

```java
@GlobalTransactional(timeoutMills = 60000,rollbackFor = Exception.class)
public Result submitById(ReportDispatchingCommand command, UserLoginDTO userLoginDTO){
    //业务逻辑
}
```

- 注意事项： 业务流程中如果涉及到`先插入`后`修改插入数据`的流程，要保证所有的`改库动作`都加`@GlobalTransactional`注解 

> 像这样，`test2`的接口加了`@GlobalTransactional`，`test3`的接口没有加`@GlobalTransactional`
> 如果执行顺序是:  `test2`执行更新 -> `test3`执行更新 -> `test2`回滚
> 这样就会由于`test3`执行了更新，导致回滚`test`的时候，`seata`认为有脏数据，就不回滚了。
> 要避免这种情况就需要给`test3`的方法也加上 `@GlobalTransactional`的注解

```java
// service A
@GetMapping("test2")
@GlobalTransactional
public void test2() {
    bService.doInsertAndUpdate();
}

// service A
// 注意这里没有加@GlobalTransactional
@GetMapping("test3")
public void test3() {
    bService.doInsertAndUpdate();
}

```





## 七、参考文档



- 参数配置文档

[spring cloud seata 参数配置](https://blog.csdn.net/weixin_43931625/article/details/104558305)

[Seata解析-TC端file.conf文件各配置作用总结](https://blog.csdn.net/weixin_38308374/article/details/108654392)



- 回滚失败

[被调用方存在两个本地事务，在调用方抛异常时，被调用方重复出现Branch Rollbacked faild](https://github.com/seata/seata/issues/3144)

