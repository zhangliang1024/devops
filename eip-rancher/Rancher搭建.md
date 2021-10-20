# RANCHER安装
> [中文官网](https://www.rancher.cn/)            
> [部署文档](https://docs.rancher.cn/docs/rancher2/quick-start-guide/deployment/_index/)              
> [培训视频](https://space.bilibili.com/430496045)
> - 至少4GB内存

---

## 一、安装基础工具
> base-build.sh
```bash
#!/bin/bash

yum install -y wget vim net-tools zip unzip
```

## 二、安装Docker
- 安装`docker`
> docker-build.sh
```bash
#!/bin/bash

echo "1.卸载旧版本docker"
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
				  
				  
echo "2.安装yum-utils"
sudo yum install -y yum-utils


echo "3.添加阿里云docker的yum源"
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	
	
echo "4.安装docker引擎"
sudo yum -y install docker-ce docker-ce-cli containerd.io

	
echo "5.启动docker"
sudo systemctl start docker

	
echo "6.运行hello-world镜像"
sudo docker run hello-world
```

- 配置镜像加速器
> - 针对Docker客户端版本大于 1.10.0 的用户
> - 您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器

> daemon-build.sh
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


- 安装`docker-compose`
> docker-compose-build.sh
```bash
#!/bin/bash

rm -rf /usr/local/bin/docker-compose

echo "1.下载docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

echo "2.授权并建立软链接"
sudo chmod +x /usr/local/bin/docker-compose

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "3.版本检查"
docker-compose --version

```

## 三、安装Rancher
> rancher-build.sh 
```bash
#!/bin/bash

docker stop rancher && docker rm rancher 

sudo docker run --privileged -d \
    --restart=unless-stopped \
    -p 80:80 -p 443:443 \
    --name rancher \
    -v /home/rancher/:/var/lib/rancher/ \
    rancher/rancher:stable

```
- 访问
> - http://xxx.130.170.xx
> - 默认用户名：admin


## 四、安装kubectl工具
> kubectl-build.sh
```bash
#!/bin/bash

echo "1.下载kubectl"
wget https://storage.googleapis.com/kubernetes-release/release/v1.18.20/bin/linux/amd64/kubectl

echo "2.移动到/usr/local/bin目录"
mv kubectl /usr/local/bin/

echo "3.赋予执行权限"
chmod +x /usr/local/bin/kubectl

echo "4.检查版本"
kubectl version --client
```

## 五、配置kube-config
> kube-config 从rancher集群中获取
```bash
#!/bin/bash

mkdir -p ~/.kube

vim ~/.kube/config

```

## 七、停止并清楚所有运行容器
> clean-build.sh
```bash
#!/bin/bash

docker stop $(docker ps -q) && docker rm $(docker ps -aq)

```


---

## 九、参考文档
* [使用Rancher部署k8s集群](https://www.jianshu.com/p/870ef7ba8723)


