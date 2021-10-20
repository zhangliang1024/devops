# `Docker`安装`jenkins`

## 一、环境准备
```properties
1. 宿主机准备
   宿主机安装JDK\MAVEN\GIT\DOCKER\NPM
2. 镜像准备
   jenkins/jenkins:latest-jdk8
```

---
## 二、`jenkins`部署

### 1.镜像下载
```bash
docker pull jenkins/jenkins:latest-jdk8
docker images | grep jenkins
```
### 2.查看镜像版本
```bash
docker inspect 44f8e2d8566c
```
### 3.启动脚本
> restart.sh
> - 挂载`docker`目录，容器里可以执行`docker`命令
> - 改用`jenkins/jenkins:latest-jdk8`版本镜像，可以安装`gitlab hook`
> - 挂载`maven`|`npm`等目录 ，`jdk`默认是：`jdk8`。否则容器内无法使用构建命令
> - `maven`要做好私服配置，仓库管理等
```bash
#!/bin/bash
  
docker stop jenkins && docker rm jenkins

docker run -d --name jenkins \
    -u root \
    --privileged=true \
    --restart=always  \
    -p 8080:8080 -p 5000:5000 \
    -v /usr/local/jenkins:/var/jenkins_home \
    -v /toony/server/apache-maven-3.6.3:/usr/local/maven \
    -v /usr/bin/docker:/usr/bin/docker \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /etc/localtime:/etc/localtime \
    -v /root/.ssh:/root/.ssh \
    jenkins/jenkins:latest-jdk8
    
#---- jenkinsci/blueocean 默认使用jdk11版本，安装gitlab hook失败 ------
   
#!/bin/bash
  
docker stop jenkins && docker rm jenkins

docker run -d --name jenkins \
        -u root \
        -p 8080:8080 -p 5000:5000 \
        -v /toony/jenkins/jenkins_home:/var/jenkins_home \
        -v /usr/local/java/jdk1.8.0_171:/var/jenkins_home/jdk8 \
        -v /toony/server/apache-maven-3.6.3:/var/jenkins_home/maven \
        -v /toony/jenkins/jenkinsci:/usr/jenkinsci \
        -v /usr/bin/docker:/usr/bin/docker \
        -v /var/run/docker.sock:/var/run/docker.sock \
        jenkinsci/blueocean

```
> docker-compose.yml
```bash
cat > docker-compose.yml <<-EOF
version: '3'
services:                                     
  docker_jenkins:
    user: root                                
    restart: always                           
    image: jenkins/jenkins:lts                
    container_name: jenkins                   
    ports:                                    
      - 8080:8080
      - 5000:5000
    volumes:                                   
      - /toony/jenkins/jenkins_home:/var/jenkins_home 
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker               
      - /usr/local/bin/docker-compose:/usr/local/bin/docker-compose
  docker_nginx:
    restart: always
    image: nginx
    container_name: nginx
    ports:
      - 8090:80
      - 80:80
      - 433:433
    volumes:
      - /toony/nginx/conf.d/:/etc/nginx/conf.d
      - /toony/webserver/static/jenkins/dist/dist:/usr/share/nginx/html
EOF	  
```

### 4.配置插件镜像加速
> - 将`url` `https://updates.jenkins.io/update-center.json`
> - 修改为 清华大学官方镜像：`https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json`
```bash
cd /usr/local/jenkins/
vim hudson.model.UpdateCenter.xml
```
### 5.访问
> http://http://xxx.61.41.102:8080
> - 用户密码：admin
```bash
cat /usr/local/jenkins/secrets/initialAdminPassword
或
docker exec -it jenkins bash cat /var/jenkins_home/secrets/initialAdminPassword
```
### 6.插件安装
> Jenkins -> Manage Jenkins -> System Configuration -> Manage Plugins -> Avaliable
```properties
Maven Integration
GitLab
GitLab Hook
SaltStack
Publish Over SSH 
Git Parameter	
Build With Parameters
Ansible
Build Pipeline
Parameterized Trigger
Parameterized Remote Trigger
Localization: Chinese (Simplified)

DingTalk
Qy Wechat Notification
build monitor view
```
![](https://ae03.alicdn.com/kf/H74d6477bb5e0415f99b1d679156c386dj.png)

---
## 三、`jenkins`配置

### 1.全局配置
> Jenkins -> Manage Jenkins -> System Configuration -> Global Tool Configuration
> - `jdk` | `maven` | `git` | `npm`

### 2.配置访问`gitlab`
> Jenkins -> Manage Jenkins -> Security -> Manage Credentials -> Stores scoped to Jenkins -> global -> Add Credentials -> Username 或者 SSH


### 3. 配置`Push SSH Server`
> Jenkins -> Manage Jenkins -> System Configuration -> Publish over SSH -> SSH Servers -> Add -> Name|Hostname|Username|Remote Directory -> Use password authentication, or use a different key


---
## 四、配置`gitlab`触发`webhook`
```properties
1. gitlabz设置root用户可以通过SSH方式拉取代码
2. Jenkins安装好插件：Credentials Plugin|Gitlab Plugin|SSH Plugin|GitLab Hook
3. jenkins添加gitlab的root用户私钥，以便后期拉取代码
4. jenkins项目构建中增加触发器：Build Triggers -> Build when a change is pushed to GitLab -> Generate
   保存：webhook URL 和 `secret token`
5. gitlab项目中：Settings -> Webhooks 添加URL和Secret token
```

- 增加触发器
![](https://ae05.alicdn.com/kf/H8e9aa1aab9e04eaf81a703ac78c7550ad.png)
- 生成`secret token`
![](https://ae06.alicdn.com/kf/Hfcf0fab9c64846488528b1552509bc89R.png)


---
## 五、安装中文插件
### 1.安装中文插件
```properties
Localization: Chinese (Simplified)
Locale plugin
```
### 2.全局配置
> Jenkins -> Manage Jenkins -> System Configuration -> Local -> Default Language : `zh_CN` 勾选 `Ignore browser ...`


---
## 六、集成`SonarQube`
### 1.安装插件
```properties
SonarQube Scanner for Jenkins
```
### 2.`SonarQube`创建`Jenkins`登录`token`
![](https://img-blog.csdnimg.cn/a02bc2212fbb433397adcb83e742c8b5.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA5oiR5Zyo5YyX5Zu95LiN6IOM6ZSF,size_20,color_FFFFFF,t_70,g_se,x_16#pic_center)

### 3.`Jenkins`配置访问`SonarQube`凭据
> Jenkins -> Manage Jenkins -> Manage Credentials ->  Stores scoped to Jenkins -> global -> Add Credentials -> Kind -> Secret text -> 填入`token`
![](https://ae05.alicdn.com/kf/Hd2eed069f91f49659c2eecf2111856a7w.png)

### 4.`Jenkins`系统配置
> Jenkins -> Manage Jenkins -> System Configuration -> SonarQube servers -> `Name、Server URL、Server authentication token`
![](https://ae03.alicdn.com/kf/H0cedee922ffc4d4894af3bfdd6a2b679H.png)

### 5.`Jenkins`全局配置
> Jenkins -> Manage Jenkins -> Global Tool Configuration -> `配置 SonarQube Scanner`
![](https://ae03.alicdn.com/kf/H07555b6f735246af939ac9b9901d71eaZ.png)

### 6.项目中配置
> 说明
```properties
sonar.projectKey=test_01                    # SonarQube中项目的唯一标识符。只要它是唯一的                
sonar.projectName=test_server               # SonarQube中项目显示的名称
sonar.version=0.0.1-SNAPSHOT                # 版本号
sonar.sources=./src                         # 源码目录
sonar.java.binaries=./target/classes        # 编译后的文件目录
# sonar.exclusions=**/*.xml,**/*.html       #排除不需要检测的文件，如：xml、html              
sonar.language=java                         # 编程语言
sonar.sourceEncoding=UTF-8
sonar.scm.disabled=true
```
![](https://ae05.alicdn.com/kf/H7878608d7e144c8eb1bb129457804de3E.png)


---
### 七、参考博客
* [jenkins jenkinsci/blueocean 使用](https://blog.csdn.net/qq_21816375/article/details/80785162)
* [docker安装jenkinsci/blueocean并且创建pipeline项目](https://blog.csdn.net/fuck487/article/details/81872182)
* [docker安装配置jenkins,并部署到其他服务器](https://blog.csdn.net/qq_21959403/article/details/110533348)
* [使用docker部署jenkins（jdk11）](https://blog.csdn.net/white_grimreaper/article/details/108282472)
* [Centos 7.8下部署Jenkins Blue Ocean-Docker版](https://zuozewei.blog.csdn.net/article/details/105856320)
* [docker安装Jenkins、jenkins插件、映射JDK和maven和RSA、publish over ssh发布](https://blog.csdn.net/jy02268879/article/details/89819598)
* [Docker手把手部署jenkins教程,jenkins容器带jdk,maven,docker,git](https://blog.csdn.net/u011526721/article/details/109481400)
* [Jenkins的安装及中文展示、安装插件创建](https://blog.csdn.net/yeyslspi59/article/details/107345085/)
* [jenkins 中文设置/中文插件](https://blog.csdn.net/cbuy888/article/details/89873892)
* ★ [jenkins部署](https://blog.csdn.net/taihexuelang/article/details/91044521)

--- 
* ★★ [配置Jenkins自动拉取gitlab中的代码并部署](https://blog.csdn.net/lee_yanyi/article/details/116235292)

---
* ★★ [sonarQube部署及Jenkins集成sonarQube](https://blog.csdn.net/weixin_44455388/article/details/120181946)
* [jenkins+sonar 持续集成检测代码质量](https://www.cnblogs.com/shenh/p/13525602.html)

---

* [Jenkins发布后-企业微信通知](https://www.cnblogs.com/Huanggang-like/p/14841337.html)
* [Jenkins配置钉钉通知](https://www.cnblogs.com/wangxu01/articles/11149851.html)
* [jenkins视图插件build monitor view](https://blog.csdn.net/testdeveloper/article/details/51743355)