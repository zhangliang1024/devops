# devops
构建devops基础环境

> 因为环境所致：在IDEA中构建的脚本，会存在windows系统和linux系统字符集不同的问题。所以在脚本上传linux系统后，要检查脚本的正确性
>
> 使用命令：cat -v clean_none_images.sh


> 执行一个容器，循环打印。不让容器退出
```bash
$ docker run -d eip-base/jdk:latest /bin/sh -c "while true;do echo hello zzyy;sleep 2;done"
```

### 官方网址

[国内镜像仓库地址](http://hub.daocloud.io/)

[Kubernets官网](https://kubernetes.io/#)

[Maven](https://maven.apache.org/)

[Jenkins](https://www.jenkins.io/)

[SonarQube](https://sonarqube.org)

[Harbor]() 