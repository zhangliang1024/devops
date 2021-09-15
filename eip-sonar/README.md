# Docker安装`SonarQube`
> - [官网](https://www.sonarqube.org/downloads/)
> - [sonarqube github](https://github.com/SonarSource/sonarqube)

---
## 一、代码审级指标
```properties
1.代码坏味道
2.bug和漏洞
3.代码重复度
4.单测与集成
```

---
## 二、SonarQube 介绍
> SonarQube 是一个用于管理源代码质量开放平台，它可以从多个维度检测代码质量，可以快速的定位代码中潜在的或者明显的 Bug、错误


---
## 三、安装部署

### 1.创建`sonar`数据库
> - 官网上已经声明 sonarQube 7.9 版本以上不再支持 mysql 了，所以我们使用 postgresql
> - 下面的`docker-compose`脚本不会自动创建数据库。所以启动`compose`后要先创建下数据后，重新启动`compose`脚本。
```yaml
[root@zhangl sonar]# docker exec -it pgdb bash
# 切换到postgres用户
root@e9bb8416e5ae:/# su postgres

root@e9bb8416e5ae:/# createdb sonar
```

### 2.创建挂载目录
> 创建目录并授权(最新版本不需要此步骤，待测试)
```bash
mkdir -p /usr/local/sonar/{extensions,logs,data,temp}
chmod 777 /usr/local/sonar/{extensions,logs,data,temp}
```

### 3.修改内核参数
> 不修改启动会报错：ERROR: Elasticsearch did not exit normally - check the logs at /opt/sonarqube/logs/sonarqube.log
```bash
vim /etc/sysctl.conf

# 增加以下配置
vm.max_map_count=262144
fs.file-max=65536

# 使配置生效
sysctl -p
```

### 4.启动`sonar`和`pgdb`
```yaml
version: "3"

services:
  sonarqube:
    #image: sonarqube:7.6-community 7.6版本安装后，商店市场中的组件无法安装
    image: sonarqube:8.9-community
    container_name: sonar
    depends_on:
      - db
    ports:
      - "9091:9000"
    networks:
      - sonarnet
    environment:
      SONARQUBE_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONARQUBE_JDBC_USERNAME: root
      SONARQUBE_JDBC_PASSWORD: 123456
    volumes:
      - /usr/local/sonar/data:/opt/sonarqube/data
      - /usr/local/sonar/extensions:/opt/sonarqube/extensions
      - /usr/local/sonar/logs:/opt/sonarqube/logs
      - /usr/local/sonar/temp:/opt/sonarqube/temp
  db:
    image: postgres
    container_name: db
    networks:
      - sonarnet
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: 123456
      POSTGRES_DB: sonar
    volumes:
      - /usr/local/postgre/postgresql:/var/lib/postgresql
      - /usr/local/postgre/postgresql/data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge

```
- 开放9000端口
```bash
# 添加9000端口
firewall-cmd --zone=public --add-port=9000/tcp --permanent
# 重新载入
firewall-cmd --reload
```

### 5.访问项目
```properties
初始用户/密码：admin/admin
```

### 6.安装插件
> 首页 -> Administration -> Marketplace - PMD\Checkstyle\Findbugs\MyBatis Plugin

---
## 四、`SonarQube`集成`Maven`
### 1、配置`maven`的`settings.xml`
```xml
<pluginGroups>
    <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
</pluginGroups>
<profiles>
    <profile>
        <id>sonar</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <sonar.host.url>http://xxx.231.202.87:9091</sonar.host.url>
        </properties>
    </profile>
</profiles>
```
### 2.项目`pom.xml`配置
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.sonarsource.scanner.maven</groupId>
            <artifactId>sonar-maven-plugin</artifactId>
            <version>3.7.0.1746</version>
        </plugin>
    </plugins>
</build>
```
### 3.执行`sonar`
- 方式一：
```bash
mvn clean verify sonar:sonar -Dsonar.login=sonar的token
```
- 方式二：
```bash
mvn  sonar:sonar  \
  -Dsonar.host.url=http://xxx.231.202.87:9091 \
  -Dsonar.login=sonar的token
  -Dsonar.projectName=项目名称
  -Dsonar.projectKey=项目Key
```
- 方式三：
```bash
mvn clean install     
mvn sonar:sonar -Dsonar.login=myAuthenticationToken
```

---
## 五、集成`gitlab-ci`
```yaml
variables:
  SONAR_PROJECT_KEY: "cloud-eureka"
  SONAR_TOKEN: "15b41b06d144017b0c9046abc8890554ba7424a6"
  SONAR_HOST_URL: "http://192.168.xxx.xx:9000"
  
stages:
  - sonar
  
sonar_preview:
  stage: sonar
  script:
    - mvn --batch-mode verify sonar:sonar -Dsonar.projectKey=$SONAR_PROJECT_KEY -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_TOKEN
  only:
    - master
  tags:
    - sonar
    
---
# Dsonar.analysis.mode已弃用
preview-sonar:
  stage: sonar
  tags:
    - sonar
  script:
    - mvn clean verify -Dmaven.test.skip=true
    - mvn -e -X --batch-mode sonar:sonar
        -Dsonar.host.url=$SONAR_HOST_URL
        -Dsonar.gitlab.commit_sha=$CI_COMMIT_SHA
        -Dsonar.gitlab.ref_name=$CI_COMMIT_REF_NAME
        -Dsonar.gitlab.project_id=$CI_PROJECT_ID
        -Dsonar.issuesReport.html.enable=true
        #设置后，sonar不创建项目，只做分析 
        #-Dsonar.analysis.mode=preview    
```

---
## 七、安装文档
### 1.插件文档
![](https://ae04.alicdn.com/kf/Haaeccdbeff8a40b29e5ffd6f47ee52a8z.png)
* [sonar-pmd-plugin](https://github.com/jensgerdes/sonar-pmd/releases/tag/3.3.1)
* [sonar-l10n-zh-plugin](https://github.com/xuhuisheng/sonar-l10n-zh/releases/tag/sonar-l10n-zh-plugin-1.16)
* [sonar-gitlab-plugin](https://github.com/gabrie-allaigre/sonar-gitlab-plugin)
* [SonarQube 系列之 — 04 插件扩展](https://www.cnblogs.com/liuyitan/p/13201602.html)

### 2.部署文档
* ★★ [sonarqube使用教程](https://www.cnblogs.com/lvlinguang/p/15192380.html)
* ★★★ [gitlab配合Sonar实现提交后自动代码检测](https://www.jianshu.com/p/8cdcb99abe72)
* ★★★ [Gitlab与Sonarqube整合-代码提交自动检测](https://www.cnblogs.com/ioops/p/14313195.html)
* ★★ [使用docker搭建sonarqube](https://www.cnblogs.com/m1996/p/14596382.html)
* [Docker安装并持久化PostgreSQL数据](https://jeecg.blog.csdn.net/article/details/100104145)
* [Docker: SonarQube 8.1安装问题](https://blog.csdn.net/Allan_shore_ma/article/details/104395900)

* ★★★ [SonarQube 系列之 — 01 安装和扫描](https://www.cnblogs.com/liuyitan/p/13157042.html)
* [CentOS7安装SonarQube并集成GitLab-CI实现代码提交后自动扫描](https://blog.csdn.net/wawa8899/article/details/118303913)
* [SonarQube 之 gitlab-plugin 配合 gitlab-ci 完成每次 commit](https://blog.51cto.com/u_4925054/2408317)
* [SonarQube 的安装、配置及 Maven 项目的使用](https://blog.csdn.net/aixiaoyang168/article/details/77565756)

* ★★ [sonarqube + jenkins + maven 项目分析](https://blog.csdn.net/dabaoting/article/details/113932549)
* [使用sonar-maven-plugin插件执行sonar扫描](https://www.jianshu.com/p/72431fe45d9e)

* []()
