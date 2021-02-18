



### 修改配置文件
```bash
#bind 127.0.0.1　　　　　　　　　　　　　　#注释掉
port 700*                               #6份配置文件，从7001到7006
appendonly yes                          #允许持久化
cluster-enable yes                      #开启集群
cluster-config-file nodes-7001.conf     #存放各节点信息，会自动生成该文件
cluster-node-timeout 15000              #节点失效检测响应的超时时间

#各节点之间通信所用ip、端口与总线端口
cluster-announce-ip 192.168.22.130      #宿主机ip
cluster-announce-port 700*              #6份配置文件，cong7001到7006
cluster-announce-bus-port 1700*         #6份配置文件，从17001到17006
```

### 参考文档

[Docker Redis5.0 集群搭建](https://www.cnblogs.com/Drajun/p/12359277.html)