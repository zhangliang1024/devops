# docker-compose 搭建Apollo

> 目前使用  `docker-compose` 的 `args`来传递 `apollo-config`、`apollo-admin`、`apollo-portal`的端口参数
>
> `args` 参数在构建过程中，会直接把参数构建到镜像中去，所以要部署多个环境。需要多次构建不同环境的镜像



### 修改 `dev.meta` 地址
> `apollo-portal/confg/apollo-env.properteis` 配置文件
