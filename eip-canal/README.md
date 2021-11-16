# docker部署canal
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
### 1. `Mysql`部署
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
```bash
show variables like 'log_bin';
```

### 2. `canal`部署
* [docker canal-server ](https://hub.docker.com/r/canal/canal-server/tags)










## 九、参考文档


--- 
> Myql

* [Mysql 用户权限管理](https://www.cnblogs.com/keme/p/10288168.html)