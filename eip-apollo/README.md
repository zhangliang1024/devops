# docker-compose 搭建Apollo

> 目前使用  `docker-compose` 的 `args`来传递 `apollo-config`、`apollo-admin`、`apollo-portal`的端口参数
>
> `args` 参数在构建过程中，会直接把参数构建到镜像中去，所以要部署多个环境。需要多次构建不同环境的镜像



### 修改 `dev.meta` 地址
> `apollo-portal/confg/apollo-env.properteis` 配置文件


### 部署方式
> `docker-compose -f docker-compose-config.yaml --compatibility up`  
>
>  由于做了资源限制, 并且没有使用`swarm`, 所以要加上`--compatibility`参数, 不然资源限制会被忽略
```bash
[root@instance-n2fyaecn apollo]# docker-compose -f docker-compose-config.yaml --compatibility up
WARNING: The following deploy sub-keys are not supported in compatibility mode and have been ignored: resources.reservations.cpus
Building apollo-configservice
Step 1/11 : FROM openjdk:8-jre-alpine
 ---> f7a292bbb70c
Step 2/11 : MAINTAINER ameizi <sxyx2008@163.com>
 ---> Using cache
 ---> 57883df07038
```