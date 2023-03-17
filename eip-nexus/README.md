# Docker安装`nexus`


### 一、环境准备
> `enxus`对服务器性能和存储要求高一点，内存不足会导致启动失败(内存溢出)。这里准备服务器4C8G
#### 镜像下载
```bash
[root@cm3gy24x0wravmtj nexus3]# docker pull sonatype/nexus3
```

### 二、部署`nexus`
#### 1.启动脚本
> `build.sh`
> - `--privileged=true` 授予root权限（挂载多级目录必须为true，否则容器访问宿主机权限不足）
```bash
#!/bin/bash

docker stop nexus3 && docker rm nexus3

docker run -d \
	--name=nexus3 \
	--restart=always \
	--privileged=true \
	-p 8081:8081 \
	-p 8080:8080 \
	-p 8000:8000 \
	-e INSTALL4J_ADD_VM_PARAMS="-Xms4g -Xmx4g -XX:MaxDirectMemorySize=8g -Djava.util.prefs.userRoot=/nexus-data/javaprefs" \
	-v /etc/localtime:/etc/localtime \	
	-v ${PWD}/nexus-data:/nexus-data \
	sonatype/nexus3:3.46.0

docker logs -f nexus3
```

#### 2.查看初始密码和配置文件
> - `docker exec -it nexus3 /bin/bash`
> - `cat nexus-data/admin.password`
> - `cat opt/sonatype/nexus/etc/nexus-default.properties`
```bash
[root@cm3gy24x0wravmtj nexus3]# docker exec -it nexus3 /bin/bash
bash-4.4$ cat nexus-data/admin.password 
3b26f919-4049-4883-85c2-7c72348d7dfb
bash-4.4$ ls
bin   dev  help.1  lib    licenses    media  nexus-data  proc  run   srv  tmp                uid_template.sh  var
boot  etc  home    lib64  lost+found  mnt    opt         root  sbin  sys  uid_entrypoint.sh  usr
bash-4.4$ ls opt/
sonatype
bash-4.4$ cat opt/sonatype/nexus/etc/nexus-default.properties 
# Jetty section
application-port=8081
application-host=0.0.0.0
nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml
nexus-context-path=/${NEXUS_CONTEXT}

# Nexus section
nexus-edition=nexus-pro-edition
nexus-features=\
 nexus-pro-feature
nexus.clustered=false
bash-4.4$ 
```

### 三、访问
> http://xxx.42.116.245:8081/
> - 注意开放端口
```text
账号：admin
密码：cb849330-c74a-4d8c-ab4a-d67daaa5a927
```

### 四、添加阿里云`maven`代理
```properties
1. 点击settings->Repository->Repositories
2. 点击Create repositoty->maven2 (proxy)
3. Name: maven-aliyun
   Proxy Remote storage: http://maven.aliyun.com/nexus/content/groups/public/
4. 滚动到页面最下方，点击“Create repositoty”按钮
5. 重新配置maven-public组,点击maven-public，进入到配置页面->把aliyun-maven移至右侧，并向上移至第一位。然后点击保存
```

### 五、配置`pom.xml`和`settings.xml`
#### 1.将jar包推送到私服
> settings.xml 中配置
```xml
<servers>
    <server>
     <!-- id自定义，pom.xml中需要与此对应 -->
        <id>maven-public</id>
        <username>admin</username>
        <password>123456</password>
    </server>
    <server>
        <id>maven-releases</id>
        <username>admin</username>
        <password>123456</password>
    </server>
    <server>
        <id>maven-snapshots</id>
        <username>admin</username>
        <password>123456</password>
    </server>
</servers>
```
> pom.xml 父依赖中配置
```xml
<!--配置上传到私服-->
<distributionManagement>
    <repository>
        <!--id的名字可以任意取，但是在setting文件中的属性<server>的ID与这里一致-->
        <id>maven-releases</id>
        <!--指向仓库类型为host(宿主仓库）的储存类型为Release的仓库-->
        <url>http://xxx.42.116.245:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>maven-snapshots</id>
        <!--指向仓库类型为host(宿主仓库）的储存类型为Snapshot的仓库-->
        <url>http://xxx.42.116.245:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```
> 执行发布 : mvn deploy

#### 2.从`nexus`中下载第三方`jar`包
> 
> - 注意下面的`server-id`的值和`mirror-id`的值需要一致，这样才能找到对应的凭证。
```xml
<servers>
    <server>
        <id>maven-public</id>
        <username>admin</username>
        <password>123456</password>
    </server>
</servers>


<mirrors>
    <mirror>
        <id>maven-public</id>
        <name>Nexus myself</name>
        <url>http://xxx.42.116.245:8081/repository/maven-public/</url>
        <!--*指的是访问任何仓库都使用我们的私服-->
        <mirrorOf>*</mirrorOf>
    </mirror>
</mirrors>

<profiles>
     <profile>
        <id>nexus</id>
        <repositories>
            <!-- 私有库地址-->
            <repository>
                <id>maven-public</id>
                <url>http://xxx.42.116.245:8081/repository/maven-public/</url>
                <releases>
                    <enabled>true</enabled>
                </releases>
                <snapshots>
                    <enabled>true</enabled>
                </snapshots>    
            </repository>
        </repositories>
        <pluginRepositories>
            <!--插件库地址-->
            <pluginRepository>
                <id>maven-public</id>
                <url>http://xxx.42.116.245:8081/repository/maven-public/</url>
                <releases>
                    <enabled>true</enabled>
                </releases>
                <snapshots>
                    <enabled>true</enabled>
                </snapshots>
             </pluginRepository>
        </pluginRepositories>
    </profile>
</profiles>

<!-- 激活 -->
<activeProfiles>
    <activeProfile>nexus</activeProfile>
</activeProfiles>

```

---
### 七、参考博客
* ★★★ [docker 搭建 nexus](https://www.jianshu.com/p/edf57ba6a159)
* ★★★ [基于nexus私服配置项目pom.xml和maven settings.xml文件](https://www.cnblogs.com/boris-et/p/13564130.html)
