# prometheus实现mysql监控

### 一、`docker`部署`mysql`
```bash
docker run -d --name mysql \
    -p 3306:3306 \
    --restart always \
    -v /opt/mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=123456 \
    --privileged=true \
    mysql:5.7
```

### 二、创建授权监控账号
```mysql
CREATE USER 'exporter'@'182.42.116.245' IDENTIFIED BY '123456';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'182.42.116.245' WITH MAX_USER_CONNECTIONS 3;
commit;
FLUSH PRIVILEGES;
select User,Host,authentication_string from mysql.user;
```

### 三、`docker`部署`mysql-exporter`
```bash
docker run -d \
	--name mysqld-exporter \
	-p 9104:9104 \
	-e DATA_SOURCE_NAME="exporter:123456@(182.42.116.245:3306)/" \
	--restart=unless-stopped \
	 prom/mysqld-exporter
```

### 四、访问`Metrics`
> http://xxx.xx.xx.x:9104/metrics


### 五、`prometheus`配置
> prometheus.yml 文件
```ymal
- job_name: 'mysql'
  static_configs:
  - targets: ['xxx.xxx.xx.x:9104']
    labels:
      instance: mysql
```



### 七、参考文档
[通过prometheus实现的docker部署mysql监控](https://blog.csdn.net/u013309797/article/details/103023562)