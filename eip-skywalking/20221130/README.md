# Skywalking集群搭建

### 一、准备工作
```properties
1. 安装好docker、docker-compose 环境
2. 下载好镜像：基于9.2.0版本
3. 安装好es|zk|kafka集群

```


### 二、

> 安装JDK环境
```shell

# 部署jdk-8u202-linux-x64.tar.gz
$ tar zxf jdk-8u202-linux-x64.tar.gz -C /opt  # 解压jdk安装包
# 添加环境变量
$ cat << EOF >> /etc/profile  
export JAVA_HOME=/opt/jdk1.8.0_202
export JRE_HOME=/opt/jdk1.8.0_202/jre
export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
EOF
$ source /etc/profile
$ java -version   # 如出现如下则安装成功
openjdk version "1.8.0_202"
OpenJDK Runtime Environment (build 1.8.0_262-b10)
OpenJDK 64-Bit Server VM (build 25.262-b10, mixed mode)

```


```shell
# SkyWalking Agent 配置
export SW_AGENT_NAME=demo-application # 配置 Agent 名字。一般来说，我们直接使用 Spring Boot 项目的 `spring.application.name` 。
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800 # 配置 Collector 地址。
export SW_AGENT_SPAN_LIMIT=2000 # 配置链路的最大 Span 数量。一般情况下，不需要配置，默认为 300 。主要考虑，有些新上 SkyWalking Agent 的项目，代码可能比较糟糕。
export JAVA_AGENT=-javaagent:/Users/yunai/skywalking/apache-skywalking-apm-bin-es7/agent/skywalking-agent.jar # SkyWalking Agent jar 地址。

# Jar 启动
java -jar $JAVA_AGENT -jar lab-39-demo-2.2.2.RELEASE.jar

#复杂脚本可参考：
nohup java -javaagent:/data/application/skywalking/agent/skywalking-agent.jar -Xmx512m -Xms512m -jar ${APP_NAME} --spring.profiles.active=dev --spring.cloud.nacos.discovery.server-addr=192.168.0.79:8848 --spring.cloud.nacos.discovery.password=nacos --spring.cloud.nacos.discovery.username=nacos --spring.cloud.nacos.config.server-addr=192.168.0.79:8848 >/dev/null 2>&1 &

```

### 五、项目使用
```shell
-javaagent:D:/Company/apache-skywalking-java-agent-8.13.0/skywalking-agent/skywalking-agent.jar
-Dskywalking.collector.backend_service=192.168.100.100:11800,192.168.100.101:21800,192.168.100.102:31800
-Dskywalking.agent.instance_name=192.168.56.1@gateway-server
-Dskywalking.agent.service_name=gateway-server
```