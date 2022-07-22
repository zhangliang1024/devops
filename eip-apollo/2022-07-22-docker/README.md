# Docker部署Apollo

### 使用官方镜像部署Apollo
[镜像地址](https://hub.docker.com/search?q=apolloconfig)

> 拉取指定版本镜像
```bash
#!/bin/bash
version=$1

docker pull apolloconfig/apollo-configservice:${version}
docker pull apolloconfig/apollo-adminservice:${version}
docker pull apolloconfig/apollo-portal:${version}
```


### 部署
```bash
sh deploy_all.sh 1.7.0
```

### 参考示例
[chenchuxin-apollo-docker](https://github.com/chenchuxin/apollo-docker)

[apollo演示场景案例](https://github.com/apolloconfig/apollo-use-cases)