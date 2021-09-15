# Linux部署`gitlab-runner`
> GitLab Runner是一个开源项目，用于运行您的作业并将结果发送回GitLab。它与GitLab CI一起使用，GitLab CI是GitLab随附的开源持续集成服务，用于协调作业。
---
## 概念介绍
### 一、`Gitlab Runner`的三种类型
```properties
shared：运行整个平台项目的作业(gitlab)
group：运行特定group下的所有项目的作业(group)
specific：运行指定的项目作业(project)
```
### 二、`Gitlab Runner`两种状态
```properties
locked：无法运行项目作业
paused：不会运行作业
```

---
## 环境准备及安装
> 服务器安装`docker、mvn、jdk、git` 用于拉取代码，项目构建、镜像构建
 
### 一、安装`gitlab-runner`
> 这里直接采用二进制安装方式，系统是：Linux x86-64
1.下载二进制文件
```bash
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
```
2.给文件操作权限
```bash
sudo chmod +x /usr/local/bin/gitlab-runner
```
3.创建执行`CI`用户并给予用户目录权限
```bash
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
chgrp gitlab-runner /usr/local/bin/gitlab-runner
```
4.安装及运行`gitlab-runner`
> `root`执行时，不需要加`sudo`
```bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```
5.添加`docker`权限
```bash
sudo groupadd docker
sudo usermod -aG docker gitlab-runner
或
sudo gpasswd -a gitlab-runner docker
```

### 二、注册`gitlab-runner`
> 说明
```properties
输入 GitLab instance URL（url和token都在gitlab的配置页面提供的）
输入 token
输入 runner的描述，有时候你的gitlab项目可能有多个runner，你需要靠这个描述来区分不同的runner
输入 tags，用英文逗号间隔
输入 runner的执行工具，这里我选的shell
```
```bash
[root@i-2vpzqimj ~]# gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=4064273 revision=58ba2b95 version=14.2.0
Running in system-mode.                            
                                                   
Enter the GitLab instance URL (for example, https://gitlab.com/):
http://182.42.116.xxx:9090
Enter the registration token:
jTPL6iZ7-mYmo6yusj7y
Enter a description for the runner:
[i-2vpzqimj]: devops
Enter tags for the runner (comma-separated):
build
Registering runner... succeeded                     runner=jTPL6iZ7
Enter an executor: custom, docker-ssh, parallels, shell, virtualbox, docker, ssh, docker+machine, docker-ssh+machine, kubernetes:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
[root@i-2vpzqimj ~]# 
```
`gitlab`查看
![](https://ae02.alicdn.com/kf/H50324bbf8daf49949ef1a6926f340bf4d.png)


### 三、邵老师文档
> 安装步骤
```bash
wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
chmod +x /usr/local/bin/gitlab-runner

useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
chgrp gitlab-runner /usr/local/bin/gitlab-runner

gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

# 添加 docker 权限：
sudo groupadd docker
sudo usermod -aG docker gitlab-runner

参考文档：https://docs.gitlab.com/runner/install/linux-manually.html
```


### 四、`Docker`部署
1.创建配置文件目录
```bash
mkdir -p /home/data/gitlab-runner/config
```
2.启动脚本
```bash
#!/bin/bash
docker stop gitlab-runner && docker rm gitlab-runner

docker run -itd --restart=always --name gitlab-runner \
        -v /home/data/gitlab-runner/config:/etc/gitlab-runner \
        -v /var/run/docker.sock:/var/run/docker.sock  \
        gitlab/gitlab-runner:latest
```
3.查看`gitlab-runner`
```bash
docker exec -it gitlab-runner bash
root@24dc60abee0b:/# gitlab-runner -v
Version:      13.8.0
Git revision: 775dd39d
Git branch:   13-8-stable
GO version:   go1.13.8
Built:        2021-01-20T13:32:47+0000
OS/Arch:      linux/amd64
```
4.注册`gitlab-runner`
```bash
[root@zhangl docker]# docker exec -it gitlab-runner bash
root@9c6c149bb634:/# gitlab-runner list
Runtime platform                                    arch=amd64 os=linux pid=28 revision=58ba2b95 version=14.2.0
Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml
root@9c6c149bb634:/# gitlab-runner -v   
Version:      14.2.0
Git revision: 58ba2b95
Git branch:   14-2-stable
GO version:   go1.13.8
Built:        2021-08-22T19:47:58+0000
OS/Arch:      linux/amd64
root@9c6c149bb634:/# 
root@9c6c149bb634:/# 
root@9c6c149bb634:/# gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=47 revision=58ba2b95 version=14.2.0
Running in system-mode.                            
                                                   
Enter the GitLab instance URL (for example, https://gitlab.com/):
http://182.42.116.xxx:9090
Enter the registration token:
jTPL6iZ7-mYmo6yusj7y
Enter a description for the runner:
[9c6c149bb634]: docker-runner
Enter tags for the runner (comma-separated):
docker
Registering runner... succeeded                     runner=jTPL6iZ7
Enter an executor: custom, parallels, ssh, virtualbox, docker+machine, docker-ssh+machine, kubernetes, docker, docker-ssh, shell:
docker
Enter the default Docker image (for example, ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
root@9c6c149bb634:/# exit
exit
[root@zhangl docker]# 
```
5.查看配置文件
```bash
vim /home/data/gitlab-runner/config/config.toml
```
6.修改配置：实现runner与宿主机的数据挂载
> 原先是volumes = ["/cache"] ，下面的volumes数组中添加docker的挂载，加快项目的构建速度。
```bash
volumes = ["/cache","/var/run/docker.sock:/var/run/docker.sock"]
```
7.重启`gitlab-runner`
```bash
docker restart gitlab-runner
```
completed_state

### 五、`gitlab-runner-monitor`部署
1.拉取镜像
```bash
docker pull timoschwarzer/gitlab-monitor
```
2.启动镜像
> gitlab-monitor-restart.sh
```bash
#!/bin/bash

docker stop monitor && docker rm monitor

docker run -d --name monitor -p 90:80 timoschwarzer/gitlab-monitor
```
3.访问
> http://111.231.202.87:90/
![](https://ae04.alicdn.com/kf/H9924a6eeacaf4b0783bf78e710d0b478D.png)
4.配置`gitlabApi`与`privateToken`
> - `gitlabApi`即`gitlab`的访问地址，在加`/api/v4`。完整路径：`http://182.42.116.xxx:9090/api/v4/projects?order_by=last_activity_at&per_page=20&membership=false`
> - `privateToken`即下图配置的`accessToken`
![](https://ae03.alicdn.com/kf/H415a0bfa0ce849768dd155a36b3f0ab76.png)

5.点击保存`save`
![](https://ae03.alicdn.com/kf/H6ece29eeae7542e1a6273e1469f73335p.png)


### 六、卸载`gitlab-runner`
```bash
!/bin/bash
# 卸载gitlab-runner

# 停止服务
gitlab-runner stop

# 卸载服务
gitlab-runner uninstall

# 清理文件
rm -rf /etc/gitlab-runner
rm -rf /usr/local/bin/gitlab-runner
rm -rf /usr/bin/gitlab-runner
rm -rf /home/data/gitlab-runner

# 删除用户
userdel -r gitlab-runner
```

### 七、常用命令
```bash
# 检查ruuner
gitlab-ci-multi-runner verify
# 去执行runner任务
gitlab-ci-multi-runner run
```
### 八、问题记录
> 此情况为：使用`gitlab-ruuner`用户来执行`docker`操作但没有赋予相应的操作权限
```bash
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.24/auth: dial unix /var/run/docker.sock: connect: permission denied
```
![](https://ae02.alicdn.com/kf/Hc25bd807ccde40ed88958c2d1f6bf8c5t.png)

> gitlab-runner一直处于pending状态原因分析
* [gitlab-runner一直处于pending状态原因分析](https://blog.csdn.net/qq_35721399/article/details/82778660)
* [gitlab runner 遇到的几个坑](https://www.jianshu.com/p/d91387b9a79b)

### 九、参考文档
* ★★★ [linux系统下Gitlab Runner安装配置](https://www.jianshu.com/p/1d67918ca61d)
* ★★★ [GitLab Runner介绍及Docker安装](https://cloud.tencent.com/developer/article/1803787)
* ★★★ [Docker安装Gitlab和Gitlab-Runner并实现项目CICD](https://segmentfault.com/a/1190000020593208)
* ★★ [Docker安装Gitlab-runner](https://www.cnblogs.com/sanduzxcvbnm/p/13815594.html)
* [gitlab-runner 安装与使用](https://www.jianshu.com/p/9da13b7790ec)
* [Gitlab Runner简单使用](https://www.cnblogs.com/wwjj4811/p/14637994.html)
* ★★ [gitlab-runner 三种runner创建和和使用](https://blog.csdn.net/weixin_43878297/article/details/119865646)
* ★★官网 [Install GitLab Runner manually on GNU/Linux](https://docs.gitlab.com/runner/install/linux-manually.html)
* [GitLab-runner的安装与卸载脚本与gitlab-runner的使用](http://t.zoukankan.com/dhu121-p-13257256.html)

* ★★★★★ [GitLab-CI/CD视频教程从入门到精通](https://fizzz.blog.csdn.net/article/details/117172382)
----
- `gitlab-runner-monitor`
* [gitlab-runner-monitor](https://github.com/werner77/gitlab-runner-monitor)
* [gitlab-monitor](https://github.com/timoschwarzer/gitlab-monitor)