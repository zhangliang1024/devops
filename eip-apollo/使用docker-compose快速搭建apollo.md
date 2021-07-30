# 使用`docker-compose`快速搭建`apollo`
> 前提：
> - 关于`apollo`的基础知识及使用方式，这里先不做介绍。可以查询官网学习。
> - 关于`docker`的使用及安装方式及`docker-compose`可以参考这里的博客。
> - 本文主旨，及在如何快速的使用`docker-compose`搭建`apollo`

## 一、创建数据表结构
### 
```properties
1. 根据`sql`目录下脚本，创建`apolloconfgidb`和`apolloportaldb`数据库
2. 初始化数据：
   apolloconfgidb库中serverconfig 表中：eureka.service.url  修改eureka地址，这里修改为apolloconfig的地址，\
                                       即docker-compose.yml中指定的EUREKA.INSTANCE.IP-ADDRESS=120.xx.xx.207，在加端口号。\
                                       即：120.xx.xx.207:9080/eureka/
   apolloportaldb库中serverconfig 表中：apollo.portal.envs  指定portal支持的环境，这里默认：dev
3. 数据库准备完毕
```

## 二、导入文件到服务器
```properties
1. 导入apollo-devops.zip到服务器目录，建议：/opt/apollo/apollo-devops/。这样可以不修改docker-compose.yml直接使用
2. 解压进入：apollo-devops
3. 修改docker-compose.yml中，数据的连接配置及注册服务IP(其中EUREKA.INSTANCE.IP-ADDRESS即为apolloconfig的地址，也即本机地址)
   environment:
     - SPRING_DATASOURCE_URL=jdbc:mysql://10.0.xxx.122:3306/apolloconfigdb?characterEncoding=utf8
     - SPRING_DATASOURCE_USERNAME=root
     - SPRING_DATASOURCE_PASSWORD=123456
     - EUREKA.INSTANCE.IP-ADDRESS=120.xx.xx.207
4. 挂载目录，视情况是否需要自定义
5. 修改docker-portal.yml中，数据的连接配置及apollo-env.properties的挂载目录
   volumes:
     - "/opt/logs/8070/100003173:/opt/logs/100003173"
     - "/opt/apollo/apollo-devops/apollo-portal/config/apollo-env.properties:/apollo-portal/config/apollo-env.properties"
   environment:
     - SPRING_DATASOURCE_URL=jdbc:mysql://10.0.xxx.122:3306/apolloportal8070?characterEncoding=utf8
     - SPRING_DATASOURCE_USERNAME=123456
     - SPRING_DATASOURCE_PASSWORD=Pdhn^456
6. 修改apollo-env.properties配置中，meta的连接地址。这里配置的portal连接apollo-config的地址
     dev.meta=http://120.xx.xx.207:9080
7. 配置文件准备完毕
```

## 三、启动`apollo`服务
```properties
1. 使用docker-compose命令启动服务(-d 后台启动)
   docker-compose -f docker-compose.yml up -d 
   docker-compose -f docker-portal.yml up -d 
2. 查看服务
   doccker-compose ps
   或者
   docker ps | grep apollo up状态为启动成功
3. 查看日志
   docker ps | grep apollo 查看容器情况
   docker logs -f 容器ID
   docker logs -f --tail 1000 容器ID
   tail -1000f /opt/logs/9080/100003171/apollo-configservice.log
```
> shell命令演示
```shell
[root@lipei92 apollo-devops]# docker-compose -f docker-compose.yml up -d
[root@lipei92 apollo-devops]# docker-compose -f docker-portal.yml up -d 
[root@lipei92 apollo-devops]# 
[root@lipei92 apollo-devops]# docker ps|grep apollo
127d43c699c5        apollo-configservice              "/apollo-configser..."   2 months ago        Up 2 months                                                                            apollo-configservice-9087
c15da0f59fcd        apollo-adminservice               "/apollo-adminserv..."   2 months ago        Up 2 months                                                                            apollo-adminservice-9086
258b8d38ecaa        apollo-portal                     "/apollo-portal/sc..."   2 months ago        Up 2 months                                                                            apollo-portal-8070
[root@lipei92 apollo-devops]# 
[root@lipei92 apollo-devops]# 
[root@lipei92 apollo-devops]# tail -1000f /opt/logs/9080/100003171/apollo-configservice.log
[root@lipei92 apollo-devops]# 
[root@lipei92 apollo-devops]# docker logs 20faafb13f4f
[root@lipei92 apollo-devops]# 
[root@lipei92 apollo-devops]# docker logs -f --tail 1000 20faafb13f4f
[root@lipei92 apollo-devops]# 
```

## 四、访问`apollo`
```properties
1. 地址：http://120.xx.xx.207:8070/signin
2. 默认用户名密码：apollo/apollo
```

## 五、项目地址
[eip-apollo](https://github.com/zhangliang1024/devops/tree/master/eip-apollo)
> 包含搭建`apollo`所需的所有资源

