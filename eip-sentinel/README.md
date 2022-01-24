# Sentinel 使用及持久化



## 二、`Sentinel`规则持久化
> `Sentinel`提供多种不同的数据源来持久化规则配置，包括：`file\redis\nacos\zk\apollo`等。因使用`Spring Cloud Alibaba`组件，所以结合`Nacos`做`Sentinel`的配置中心

- 动态实现数据源原理
![](https://ae02.alicdn.com/kf/Hfa56ccef804f456b86afc6932ba75063E.png)


### 1.`Sentinel`规则推送的三种模式
![](https://ae04.alicdn.com/kf/H86b6847b1dcb47e8a2f640d88fbcf1f1O.png)
- 采用`Push`模式流程图
> `Sentinel-dashboard`统一管理配置，同时下发配置生成`Rule`，如下图(虚线部分支持，但不推荐)
![](https://ae05.alicdn.com/kf/H8978938071ef4b17a485a8f904299cfb9.png)

### 2.源码改造
> 目前采用版本：`1.8.0`不支持配置持久化，故做一定改造
> - 规则入口类改造，即`controller`部分
> - 规则的动态拉取、发布实现，即`rule`部分

![](https://ae02.alicdn.com/kf/H26dd56fdc916443cb2c870fe153e0747z.png)


### 3.项目集成
- `pom.xml`依赖
```xml
<!-- 通过nacos持久化流控规则 -->
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-datasource-nacos</artifactId>
</dependency>
<!-- sentinel 整合spring cloud alibaba -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
</dependency>
<!-- sentinel客户端与dashboard通信依赖 -->
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-transport-simple-http</artifactId>
</dependency>
```

- `application.yml`配置文件
```yaml
spring:
  application:
    name: sentinel-server
  cloud:
    sentinel:
      #取消Sentinel控制台懒加载
      eager: true
      transport:
        #连接sentinel dashbaord地址
        dashboard: localhost:8080
      datasource:
        flow:
          nacos:
            #连接nacos地址
            server-addr: 127.0.0.1:8848
            #文件配置规则
            dataId: ${spring.application.name}-flow-rules.json
            #配置分组
            groupId: SENTINEL_GROUP
            #规则类型
            rule-type: flow
        degrade:
          nacos:
            server-addr: 127.0.0.1:8848
            dataId: ${spring.application.name}-degrade-rules.json
            groupId: SENTINEL_GROUP
            rule-type: degrade
        system:
          nacos:
            server-addr: 127.0.0.1:8848
            dataId: ${spring.application.name}-system-rules.json
            groupId: SENTINEL_GROUP
            rule-type: system
        authority:
          nacos:
            server-addr: 127.0.0.1:8848
            dataId: ${spring.application.name}-authority-rules.json
            groupId: SENTINEL_GROUP
            rule-type: authority
        param-flow:
          nacos:
            server-addr: 127.0.0.1:8848
            dataId: ${spring.application.name}-param-flow-rules.json
            groupId: SENTINEL_GROUP
            rule-type: param-flow
```
- 动态配置
> 支持`sentinel dashboard`通过簇点链路或其它配置规则入口进行规则配置。

- `Nacose`配置示例
> 在`snetinel`配置后推送到`nacos`存储

![](https://ae01.alicdn.com/kf/H24923bbb1bc2462ba13502e697d6c5cc1.png)
- `Nacose`配置详情示例

![](https://ae05.alicdn.com/kf/H6bd6e47730e64347b7ddc052695ca8bfl.png)


### 4.自定义配置示例
- `Nacos`配置示例
```json
[
    {
        "resource": "/hello",
        "limitApp": "default",
        "grade": 1,
        "count": 5,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    }
]
```
- 配置说明
```properties
resource : 资源名，限流规则作用对象，一般为请求URI
limitApp : 控流针对的调用来源，default则不区分调用来源
grade    :  限流阈值类型；0表示根据并发量来限流，1表示根据QPS来进行限流
count    :  限流阈值
strategy ： 调用关系限流策略
controlBehavior ： 限流控制行为（快速失败 、warm up 、排队等候）
clusterMode     ： 是否为集群模式 

```

---
## 五、参考文档
 * ★ [docker化sentinel-dashboard+nacos注册中心](https://www.jianshu.com/p/c3dc1757033f)
 * ★★★ [Sentinel1.8.0配置持久化到Nacos（基于push模式）](https://www.jianshu.com/p/9a6cf8634805)
 * []()
 * [SpringCloud使用Sentinel 代替 Hystrix](https://blog.csdn.net/u011277123/article/details/92763625)
 * []()


