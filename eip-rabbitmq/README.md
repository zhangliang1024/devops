# `docker`部署`rabbitMq`

### 一、部署
> - `management`下载的镜像包含：`manage`模块和`web`管理也
> - `RABBITMQ_DEFAULT_USER`和`RABBITMQ_DEFAULT_PASS` 指定`manage`的用户名和密码
>    - 若不指定，默认用户名密码：`guest` `guest` 
```bash
docker run -dit --name mymq -p 15672:15672 -p 5672:5672 -e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=admin rabbitmq:management
```

### 二、访问
> http://xxx.xxx.xx.xx:15672

### 三、失败
```properties
如果访问失败，可能是没有开启manage模块。

通过docker ps -a查看部署的mq容器id，在通过 docker exec -it 容器id /bin/bssh 进入容器内部在
运行：rabbitmq-plugins enable rabbitmq_management，执行完毕后重新访问web界面即可。
```