# Seata-Server部署




### Seata-server使用Eureka注册中心
> registry
```conf
registry {
  # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
  type = "eureka"
  loadBalance = "RandomLoadBalance"
  loadBalanceVirtualNodes = 10
  eureka {
    serviceUrl = "http://10.0.17.92:9001/eureka"
    application = "seata-server"
    weight = "1"
  }
}

config {
  # file、nacos 、apollo、zk、consul、etcd3
  type = "apollo"

  apollo {
    appId = "seata-server"
    apolloMeta = "http://10.0.17.92:9080"
    namespace = "application"
  }
}
```


### 七、参考文档
[]()
[]()
[]()
[]()
[]()
[]()
[]()
[zhanglning/seata-docker](https://gitee.com/zhanglning/seata-docker/tree/master)
[seata/seata-docker](https://github.com/seata/seata-docker)

[使用 Docker 部署 Seata Server](http://seata.io/zh-cn/docs/ops/deploy-by-docker.html)