# Docker搭建Redis






### 参考文章

[基于Docker-Compose搭建Redis集群](https://segmentfault.com/a/1190000023965730)

[基于Docker搭建Redis集群（主从集群）](https://www.cnblogs.com/niceyoo/p/14118146.html)

[使用docker搭建redis集群（两种方式）](https://blog.csdn.net/weixin_44015043/article/details/105868513)


[必须是全网最全的Redis集群搭建教程](https://segmentfault.com/a/1190000015795054)


### 配置文件

[redis数据库的配置文件redis.conf详解](https://blog.csdn.net/weixin_36065860/article/details/109025668)


## 问题

### 1. 配置文件信息有问题，导致集群启动报错
```text
Unrecoverable error: corrupted cluster config file
```
> 解决：使用一份新的配置，或者修改配置文件

[Unrecoverable error: corrupted cluster config file](https://www.cnblogs.com/wq3435/p/9881198.html)