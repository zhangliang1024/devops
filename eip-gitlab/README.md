# Docker安装`Gitlab`

### 一、环境资源
```properties
1. Linux CentOs8版本
2. 配置：4C8G (非常占内存)
3. 镜像：gitlab-ce (免费社区版)
```

### 二、`gitlab`准备
#### 1.镜像
```bash
[root@zhangl gitlab]# docker pull gitlab/gitlab-ce:latest
[root@zhangl gitlab]# docker images|grep gitlab
```
#### 2.文件映射
```bash
[root@zhangl gitlab]# mkdir -p /usr/local/gitlab/{config,data,logs}
[root@zhangl gitlab]# cd /usr/local/gitlab
```
文件宿主机位置|文件容器位置|作用
---|---|---
/usr/local/gitlab/config | /etc/gitlab | 用于存储gitlab配置文件
/usr/local/gitlab/data | /var/log/gitlab | 用于存储gitlab日志
/usr/local/gitlab/logs | /var/opt/gitlab | 用于存储应用数据

#### 3.创建启动脚本
> - GITLAB_ROOT_PASSWORD : 密码必须大于8位
> - 注意端口占用情况
> - 这里使用非标准端口脚本

- `build.sh`
```bash
#!/bin/sh

docker stop gitlab && docker rm gitlab

GITLAB_HOME=/usr/local/gitlab

docker run -d --name gitlab \
    --hostname 140.246.xxx.99 \
    -p 3003:443 \
    -p 3080:3080 \
    -p 3002:22 \
    --restart always \
    --privileged=true \
    -v $GITLAB_HOME/config:/etc/gitlab \
    -v $GITLAB_HOME/logs:/var/log/gitlab \
    -v $GITLAB_HOME/data:/var/opt/gitlab \
    -e GITLAB_ROOT_PASSWORD=12345678 \
    gitlab/gitlab-ce:latest
    
```
> 参数说明
```properties
 --hostname : 设置主机名或域名
 --publish : 端口映射
 --name : 运行容器名
 --restart always : 自动重启
 --volume : 目录挂载
 -e : 环境变量赋值
```
> 状态查看
```bash 
[root@zhangl gitlab]# docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED        STATUS                 PORTS                                                               NAMES
e3b38561ddd3   gitlab/gitlab-ce:latest   "/assets/wrapper"        3 hours ago    Up 3 hours (healthy)   0.0.0.0:10080->22/tcp, 0.0.0.0:9091->80/tcp, 0.0.0.0:445->443/tcp   gitlab
```
> `STATUS`为`health: starting`，说明`gitlab`的服务正在启动中，还没有启动完毕。等这个状态变成`healthy`时则说明已经部署完成，可以访问了。

### 三、访问
> - 云服务器安全组开放端口
> http://111.xxx.xxx.87:3080
> - 用户名密码：root/12345678

### 四、修改配置
> vim config/gitlab.rb
#### 1.配置外部访问地址
```bash
# 配置外部访问地址
external_url 'http://182.42.116.xxx:3080'
nginx['redirect_http_to_https_port'] = 3080
nginx['listen_port'] = 3080

gitlab_rails['gitlab_ssh_host'] = '182.42.116.xxx'
# 此端口是run时22端口映射的2222端口
gitlab_rails['gitlab_shell_ssh_port'] = 3002
```
#### 2.使用默认配置
> ** 这里使用如下配置，做了下载的端口配置 **
```bash
#配置http协议所使用的访问地址,不加端口号默认为80
external_url 'http://182.42.116.xxx:3080'
nginx['listen_port'] = 3080
# 配置ssh协议所使用的访问地址和端口
gitlab_rails['gitlab_ssh_host'] = '182.42.116.xxx'
# 此端口是run时22端口映射的2222端口
gitlab_rails['gitlab_shell_ssh_port'] = 3002
```

> 重新加载配置
```bash
[root@cm3gy24x0wravmtj gitlab]# docker exec gitlab gitlab-ctl reconfigure
[root@cm3gy24x0wravmtj gitlab]# docker exec gitlab gitlab-ctl restart
```

#### 3. 查看配置
```bash
# gitlab映射到宿主机的配置
vim config/gitlab.rb
# 执行gitlab-ctl reconfigure后，配置会刷新到这里
vim data/nginx/conf/gitlab-http.conf

# 进入gitlab容器，查看配置
docker exec -it gitlab /bin/bash
vi /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml
```

#### 4. 仓库下载地址
> 下载地址带了配置的端口

<img src="http://tva1.sinaimg.cn/large/d1b93a20ly1h84vulkxm9j20qq0ef0vz.jpg"/>



### 六、[`Gitlab`重置管理员密码](https://www.cnblogs.com/ccbloom/p/14629536.html)
```bash
[root@zhangl gitlab]# docker exec -it gitlab /bin/bash
root@182:/# su - git
$ ls
alertmanager  bootstrapped  gitaly     gitlab-exporter  gitlab-shell      grafana    nginx              postgresql  redis
backups       git-data      gitlab-ci  gitlab-rails     gitlab-workhorse  logrotate  postgres-exporter  prometheus  trusted-certs-directory-hash
$ gitlab-rails console -e production
--------------------------------------------------------------------------------
 Ruby:         ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]
 GitLab:       13.9.3 (ea359c58edb) FOSS
 GitLab Shell: 13.17.0
 PostgreSQL:   12.5
--------------------------------------------------------------------------------
Loading production environment (Rails 6.0.3.4)
irb(main):001:0> user = User.where(id: 1).first        # 指定root账户
=> #<User id:1 @root>
irb(main):002:0> user.password = 'adsasdasdasdas'      # 设置密码
=> "adsasdasdasdas"
irb(main):003:0> user.password_confirmation = 'password'    # 确认密码
=> "adsasdasdasdas"
irb(main):004:0> user.save!      # 保存配置
Enqueued ActionMailer::MailDeliveryJob (Job ID: cc20a600-f7ba-45d1-93fd-ca8e4cb4ccba) to Sidekiq(mailers) with arguments: "Dev
=> true
irb(main):005:0> exit
```

### 七、`gitlab`使用
- `gitlab`分支保护
> 保护特定分支不被随便合并
```properties
1.Gitlab -> 具体项目 -> Settings -> Repository -> Protected branches
```

- `Developer`可以推送代码
```properties
1.Gitlab -> 具体项目 -> Settings -> Repository -> Protected branches -> Allowed to push -> Developer+Maintainer
```

### 九、参考文档
* [官网文档](https://docs.gitlab.com/)
* [使用Docker部署GitLab](https://juejin.cn/post/6991435962303643679)
* [Docker搭建Gitlab私服](https://www.jianshu.com/p/76ae9c65861c)
* ★★★ [docker安装gitlab并使用非标准端口](https://blog.csdn.net/ming19951224/article/details/105479033)

* [使用Docker 搭建 GitLab中文版--1](https://blog.csdn.net/wudibaba21/article/details/115415280)

