# Rocket Docker-compose部署双主模式

### 使用版本
> [`foxiswho/rocketmq:4.8.0`](https://hub.docker.com/r/foxiswho/rocketmq)

### 注意事项
> - `4.7.0`及以后 版本镜像,将不在根据`base`镜像生成`server`,broker`镜像，统一使用`base`镜像，两者区别只是调用的启动文件不同
> - `broker`目录映射: 映射本地目录`logs`权限一定要设置为`777`权限，否则启动不成功


### 参考文档
[Docker-Compose部署RocketMQ集群双主模式](https://blog.csdn.net/qq_33449307/article/details/119304128)