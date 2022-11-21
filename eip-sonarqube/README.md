# Docker安装SonarQube

### 一、简介
> [SonarQube](https://www.sonarqube.org/) 是一款用于代码质量管理的开源工具，主要用于源码的质量管理。通过插件形式，可以支持多种语言。


### 二、准备工作
-  创建自定义网络
> `SonarQube`安装需要用到`Postgres`数据库。故需要准备一个可以相互连通的网络

```bash
docker network create --driver bridge --subent 172.0.0./16 sonarqube
docker network ls 
```

- 下载镜像
```bash
docker pull postgres:latest
docker pull sonarqube:8.9.10-community
```

### 三、安装`Postgres`

- 创建日志/数据目录
```bash
mkdir -p /opt/postgresql/{logs,data}
```

- 安装脚本
> `build.sh`
```bash
#!/bin/bash

docker stop postgres && docker rm postgres

sudo docker run -d \
    -p 5432:5432 \
    --name postgres \
    --restart=always \
    --network sonarqube \
    --ip 172.0.0.54 \
    -v ${PWD}/data:/var/lib/postgresql/data \
    -e POSTGRES_USER=sonar \
    -e POSTGRES_PASSWORD=sonar \
    postgres

docker logs -f postgres
```

- 登录测试
```bash
docker exec -it postgresql /bin/bash

# postgres登录 
psql -U sonar -W 
```

### 四、安装`SonarQube`

- 修改Linux最大虚拟内存配置
> 不修改配置，启动报错：max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```bash
vim /etc/sysctl.conf

# 加入如下配置
vm.max_map_count = 26214
```

- 创建日志/数据/插件 目录
```bash
mkdir -p /opt/sonarqube/{logs,data,extensions}
```

- 安装脚本
> `build.sh`
```bash
#!/bin/bash

docker stop sonarqube && docker rm sonarqube

sudo docker run -d \
    -p 3009:9000 \
    --name sonarqube \
    --restart=always \
    --network sonarqube \
    --ip 172.0.0.59 \
    -v ${PWD}/extensions:/opt/sonarqube/extensions \
    -v ${PWD}/data:/opt/sonarqube/data \
    -v ${PWD}/logs:/opt/sonarqube/logs \
    --link postgresql \
    -e sonar.jdbc.url=jdbc:postgresql://postgresql:5432/sonar \
    -e sonar.jdbc.username=sonar \
    -e sonar.jdbc.password=sonar \
    sonarqube:8.9.10-community

docker logs -f sonarqube

```

- 访问
> http://xxx.xxx.xx:3009
> 
> admin/admin


### 五、`Sonarqube`的使用方式
- 基于`Maven`的方式
> 修改`maven的settings.xml`文件
```xml
<profiles>
    <profile>    
        <id>jdk1.8</id>    
        <activation>    
            <activeByDefault>true</activeByDefault>    
            <jdk>1.8</jdk>    
        </activation>    
        <properties>    
            <maven.compiler.source>1.8</maven.compiler.source>    
            <maven.compiler.target>1.8</maven.compiler.target>    
            <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>    
        </properties>     
    </profile>
    <profile>
        <id>sonar</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <sonar.login>admin</sonar.login>
            <sonar.password>abcd1234</sonar.password>
            <sonar.host.url>http://xxx.xxx.xx.xx:3009</sonar.host.url>
        </properties>
    </profile>
<profiles>
    
<activeProfiles>
    <activeProfile>jdk8</activeProfile>
    <activeProfile>sonar</activeProfile>
</activeProfiles>
```
> 在代码中使用命令
```bash
mvn sonar:sonar
```

- 基于`sonar-scannner`的方式

[下载地址](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)

> 解压到`Jenkins`的`jenkins_home`目录中
```bash
# 解压
unzip sonar-scanner-cli-4.7.0.2747-linux.zip

# 移动到jenkins_home目录下
cd /opt/jenkins/jenkins_home
mv /opt/install/sonar-scanner-cli-4.7.0.2747-linux ./sonar-scanner
```

> 修改`sonar-scanner`配置
```bash
cd sonar-scanner
vim conf/sonar-scanner.properties

# 修改连接sonarqube地址，这里可以不指定用户名、密码。通过token方式来访问
sonar.host.url=http://140.xx.xx.99:9000
sonar.sourceEncoding=UTF-8
```

> 命令行使用
```bash
# 在项目目录下
cd /opt/jenkins/jenkins_home/workspace/eip-test

# 执行检测命令
/opt/jenkins/jenkins_home/sonar-scanner/bin/sonar-scanner \
-Dsonar.projectname=eip-test \
-Dsonar.sources=./ \
-Dsonar.java.binaries=./target/ \
-Dsonar.login=0f24d3019b195a3d121e728235f3cd1c595496f8 \
-Dsonar.projectKey=eip-test
```

> `Jenkins`整合`sonar-scanner`插件
```properties
SonarQube Scanner
```

> `Jenkins`系统管理`sonar-scanner`配置
```properties
1. SonarQube servers
2. Name
3. Server Rul
4. authentication token
```

> `Jenkins`全局工具配置`sonar-scanner`
