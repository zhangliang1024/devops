# Shell部署Zookeeper集群
> 单节点集群，`Shell`脚本部署更灵活。如需要扩容，修改`count`值即可。

### 一、说明
- 配置说明
```properties
count：集群节点数
network_name：集群所在网络名
client_port_start：集群绑定主机初始节点（不包括这个临界值）
name_prefix：集群容器名前缀
```

- 启动说明
```bash
# 添加可执行权限,不添加可执行权限则可直接使用 /bin/bash zookeeper.sh 执行，用dash或者sh命令可能会报错
sudo chmod +x zookeeper.sh
# 启动
./zookeeper.sh up
# 停止 
./zookeeper.sh down
```