# Prometheus+Grafana做服务监控


## 一、部署

### 1. 启动/重启/停止/卸载
```bash
docker-compose up -d
docker-compose restart
docker-compose stop
docker-compose down
```
### 2.`prometheus`动态加载配置文件
> 使用`--web.enable-lifecycle`来实现配置动态加载
```bash
docker run -d -p 9091:9090 --name prom -v /home/monitor/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle

curl -X POST http://192.168.X.X:9090/-/reload
```


## 二、项目配置
### 1.`pom.xml`依赖
```xml
 <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

### 2.`application.yml`配置
```yml
management:
  endpoints:
    web:
      exposure:
        include: "*"
```

## 三、使用
### 1.访问地址
> - Grafana: http://xxx.xx.xx.x:3000  
>   - 默认用户名/密码：admin/admin
> - Prometheus: http://xxx.xx.x:9090

### 2.模板推荐
> [模板查询](https://grafana.com/grafana/dashboards/?)
```properties
node 11074
mysql 7362
druid 11157
redis
springboot 12900
elasticsearch
pod
```


## 四、`exporter`
```bash
docker pull bitnami/mysqld-exporter
docker pull bitnami/redis-exporter
docker pull bitnami/elasticsearch-exporter
```

### mysql授权
```bash
CREATE USER 'exporter'@'182.42.116.245' IDENTIFIED BY '123456';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'182.42.116.245' WITH MAX_USER_CONNECTIONS 3;
commit;
FLUSH PRIVILEGES;
select User,Host,authentication_string from mysql.user;
```

### mysqld-exporter部署

```bash
date -R
mv /etc/timezone /etc/timezone-`date +%Y%m%d-%H%M%S`
echo 'Asia/Shanghai' > /etc/timezone
mv /etc/localtime /etc/localtime-`date +%Y%m%d-%H%M%S`
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

docker pull prom/mysqld-exporter
docker rm -f mysqld-exporter
docker run -d \
--name mysqld-exporter \
-v /etc/timezone:/etc/timezone \
-v /etc/localtime:/etc/localtime \
-p 9104:9104 \
-e DATA_SOURCE_NAME="exporter:password@(192.168.1.1:3306)/" \
--restart=unless-stopped \
prom/mysqld-exporter
docker logs -f --tail 10 mysqld-exporter
```

