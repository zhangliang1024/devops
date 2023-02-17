###

### 创建用户
> 创建Elasticsearch启动用户，并设置权限
```shell
groupadd elastic
useradd elastic -g elastic -p elastic
chown -R elsearch:elsearch elasticsearch-7.2.0
```
> 切换用户
```shell
su elastic
```

### 服务器配置
> 修改打开最大文件数
```shell
vim /etc/security/limits.conf
# 添加以下内容：
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
```
> 修改系统虚拟内存大小
```shell
vim /etc/sysctl.conf
vm.max_map_count=655360
```

```shell
sysctl -p
```
- 参考配置
```shell
cluster.name: elasticsearch-cluster
node.name: node-1
http.port: 9200
#path.data: /opt/elasticsearch/data
#path.logs: /opt/elasticsearch/logs

# ES监听的ip地址
network.host: 0.0.0.0
cluster.initial_master_nodes: ["node-1"]

# 需要开启跨域才能给elasticsearch-head，kibana等连接
http.cors.enabled: true
http.cors.allow-origin: "*"
#http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
```

- `elasticsearch.yml` 配置
```bash
cluster:
  name: elasticsearch
http:
  port: 9200
  cors:
    enabled: true
    allow-origin: "*"
path:
  data: /bitnami/elasticsearch/data
transport:
  tcp:
    port: 9300
network:
  host: 172.17.0.2
  publish_host: 172.17.0.2
  bind_host: 0.0.0.0
node:
  name: elasticsearch
  master: true
  data: true
  ingest: false
discovery:
  type: single-node 
```