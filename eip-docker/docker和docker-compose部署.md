# `Linux`搭建`docker`及`docker-compose`
> 介绍`docker`及`docker-compose`的安装

---
## 一、`docker`搭建
> 在线安装  [docker-install](https://docs.docker.com/engine/install/centos/)

### 1. 配置`yum`源阿里云镜像
```properties
1. 备份原来的yum源
   cd /etc/yum.repos.d/
   cp CentOS-Base.repo CentOS-Base.repo_bak

2. 获取阿里云yum源
   wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

3. 清除原有yum源缓存
   yum clean all

4. 生产阿里云yum缓存
   yum makecache
```
### 2. 卸载旧版本
```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```
### 3. 安装`yum-utils`，它提供了`yum-config-manager`，可用来管理`yum`源
```bash
sudo yum install -y yum-utils
# 添加阿里云docker的yum源
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```
### 4. 安装`docker`引擎
> 默认安装最新版本
```bash
sudo yum -y install docker-ce docker-ce-cli containerd.io
```
- 可以通过以下命令来安装指定版本
> yum list docker-ce --showduplicates | sort -r
```bash
[root@zhangl ~]# yum list docker-ce --showduplicates | sort -r
docker-ce.x86_64            3:20.10.7-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.6-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.5-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.4-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.3-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.2-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.2-3.el7                    @docker-ce-stable
docker-ce.x86_64            3:20.10.1-3.el7                    docker-ce-stable 
docker-ce.x86_64            3:20.10.0-3.el7                    docker-ce-stable 
```
> sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
>
> - 包名称(docker-ce)加上从第一个冒号(:)开始的版本字符串(第2列)，直到第一个连字符，由连字符(-)分隔。例如，docker-ce-18.09.1
```bash
sudo yum install docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io
```

### 5. 启动`docker`
```bash
sudo systemctl start docker
```
### 6. 运行测试镜像
```bash
sudo docker run hello-world
```

### 7. 配置镜像加速器
> - 针对Docker客户端版本大于 1.10.0 的用户
> - 您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://p37cu8pf.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 二、`docker`版本与`docker-compose `版本关系
> [版本关系](https://docs.docker.com/compose/compose-file/compose-file-v3/) 不同版本支持的语法格式不同

![docker-compose与docker之间版本关系](D:/User/devops/eip-apollo/docker-compose与docker之间版本关系.png)

---

## 三、`docker-compose`搭建
> 在线安装 [docker-compose-install](https://docs.docker.com/compose/install/)

### 1. 下载`docker-compose`
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
### 2. 赋予执行权限
```bash
sudo chmod +x /usr/local/bin/docker-compose
```
### 3. 建立软连接
```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
### 4. 查看版本
```bash
docker-compose --version
```

---
### 四、参考博客
[centOS7配置yum阿里源并安装docker最新版](https://blog.csdn.net/qq_40715775/article/details/85913994)

[centos7使用国内源安装指定版本docker，docker-compose，配置阿里云docker镜像加速器](https://www.cnblogs.com/yyee/p/12905165.html)

[docker-compose教程（安装，使用, 快速入门）](https://blog.csdn.net/pushiqiang/article/details/78682323)

[Docker Compose file](https://www.cnblogs.com/cjsblog/p/10888778.html)

[docker-compose](https://www.cnblogs.com/-wenli/p/13734852.html)


