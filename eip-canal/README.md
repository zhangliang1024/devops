# docker部署canal
> 详细文档参考：[语雀](https://www.yuque.com/noone-5u1t7/fdbfys/qz9czu)

## 一、说明
> [`Canal`](https://github.com/alibaba/canal)是阿里巴巴开的开源项目，纯`java`开发。基于数据库增量日志解析，提供增量数订阅与消费。

- 工作模式

![](https://ae02.alicdn.com/kf/Hd84bf25b0eec4589b6f8b31298cba3bdo.png)

- Mysql同步选型

![](https://img-blog.csdnimg.cn/20190316164050790.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljLmJsb2cuY3Nkbi5uZXQ=,size_16,color_FFFFFF,t_70)

## 二、组件介绍
> - `canal-admin` : 为`canal`提供整体配置管理、节点运维等功能。
> - `canal-server`: 服务端从`Mysql`读取`binlog`增量日志。
> - `canal-adapter`: 客户端根据`canal-server`读取的增量日志执行适配到其它如：es\redis\mysql等，实现数据同步。



## 三、组件部署
### 1. 版本环境
```properties
mysql:5.7.18
elasticsearch:6.4.0 
elasticsearch-head-master  // elaticsearch Web端监控
elasticsearch-analysis-ik:6.4.0  // elastics-ik 中文分词器（插件）
canal.server:1.1.4   // canal数据同步server端
canal.adapter:1.1.4  // canal数据同步适配器

# 注意
最好版本保持一致进行测试、版本不一致可能出现一系列问题，后续看升级mysql8.X可能出现的问题在最后面有列举

★ 项目中实际使用版本
mysql:5.7
elasticsearch:7.6.2
canal.server:1.1.5   // canal数据同步server端
canal.adapter:1.1.5  // canal数据同步适配器
```

### 2. 镜像下载
```properties
# mysql
docker pull mysql:5.7

#canal相关
docker pull canal/canal-admin:v1.1.4
docker pull slpcat/canal-adapter:v1.1.4
docker pull canal/canal-server:v1.1.4

docker pull slpcat/canal-adapter:v1.1.5
docker pull canal/canal-server:v1.1.5
docker pull canal/canal-admin:v1.1.5

#elasticsearch kibana
docker pull elasticsearch:7.6.2
docker pull kibana:7.6.2
```

### 3. 部署搭建
#### 3-1. `Mysql`部署
- 创建文件
```bash
mkdir -p /toony/mysql/{data,conf,log}
```
- 配置`my.cnf`
```properties
log-bin=mysql-bin 　　# 开启 binlog
binlog-format=ROW 　　# 选择 ROW 模式
server_id=3306 　　　 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
```
> vim /toony/mysql/conf/my.cnf
```bash
[client]
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
init_connect='SET collation_connection = utf8_unicode_ci'
init_connect='SET NAMES utf8'
character-set-server=utf8
max_allowed_packet=4M
collation-server=utf8_unicode_ci
skip-character-set-client-handshake
skip-name-resolve

server-id=3306
log-bin=mysql-bin
binlog_format=ROW
```

- 部署脚本
```bash
#!/bin/bash

docker stop mysql && docker rm mysql

docker run -p 3306:3306 --name mysql \
     -v /toony/mysql/log:/var/log/mysql \
     -v /toony/mysql/data:/var/lib/mysql \
     -v /toony/mysql/conf:/etc/mysql \
     -v /etc/timezone:/etc/timezone \
     -e MYSQL_ROOT_PASSWORD=123456 \
     -d mysql:5.7
```

- 创建同步账号
```bash
# 进入容器，登录mysql
docker exec -it mysql /bin/bash
mysql -uroot -p123456

# 配置账号
use mysql;
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT on *.* to 'canal'@'%' identified by "canal";
flush privileges;
```

- mysql给用户授予所有权限
> 格式：grant 权限 on 数据库名.表名 to 用户@登录主机 identified by “用户密码”
```bash
GRANT ALL PRIVILEGES ON *.* TO "canal"@"%" IDENTIFIED BY "canal" WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

- 查看`binlog`是否开启
> 验证`mysql binlog`，`log_bin`为`ON`，则为开启`mysql binlog`
```bash
show variables like 'log_bin';
```

#### 3-2. 部署`elasticsearch`
- 系统配置 
```bash
[root@i-2vpzqimj ~]# sudo vi /etc/security/limits.conf
soft nofile 65536  
hard nofile 65536 

[root@i-2vpzqimj ~]# sudo vi /etc/sysctl.conf
vm.max_map_count=655360
```

- 编辑配置 `elasticsearch.yml`
```bash
cluster.name: elasticsearch

node.name: node1

network.host: 0.0.0.0
http.port: 9200

http.cors.enabled: true
http.cors.allow-origin: "*"

node.master: true
node.data: true
```

- 部署`elasticsearch`
```bash
#!/bin/bash

docker stop elasticsearch && docker rm elasticsearch

docker run --restart=always \
      --name='elasticsearch' \
			-p 9200:9200 -p 9300:9300 \
      -e "discovery.type=single-node"\
      -v /root/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
      -d elasticsearch:7.6.2
```

- `kibana`部署
```bash
#!/bin/bash

docker stop kibana && docker rm kibana

docker run --name kibana \
			--link bc1545752398:elasticsearch \
      -p 5601:5601 \
      -d kibana:7.6.2
```
> 访问  http://139.198.xx.xx:5601/


#### 3-3. 部署`canal`
* [docker canal-server ](https://hub.docker.com/r/canal/canal-server/tags)

```bash
#!/bin/bash
docker stop canal-server && docker rm canal-server
	
docker run -d -it -h 0 \
	-e canal.admin.manager=192.168.100.54:8089 \
    -e canal.admin.port=11110 \
    -e canal.admin.user=admin \
    -e canal.admin.passwd=4ACFE3202A5FF5CF467898FC58AAB1D615029441 \
    --name=canal-server \
    -p 11110:11110 \
    -p 11111:11111 \
    -p 11112:11112 \
    -m 1024m canal/canal-server:v1.1.5
```



## 九、参考文档


--- 
> Myql

* [Mysql 用户权限管理](https://www.cnblogs.com/keme/p/10288168.html)