# 基于`Docker`部署`skywalking`实现全链路追踪
> `Skywalking`是一个可观测性分析平台(`Observability Analysis Platform`简称OAP) 和 应用性能管理系统
(`Application Performance Management`简称APM)
> - 提供分布式链路追踪、服务网格(`Service Mesh`)遥测分析、度量聚合和可视化一体解决方案
> - [官方下载地址](http://skywalking.apache.org/downloads/)

### 一、环境说明
```properties
1. 操作系统：CentOS8.2 
2. docker版本：20.10.8
3. docker-compose版本：1.29.2
4. 配置：4c8g
```

#### - 环境安装
##### 二进制安装
> 运行`bin目录`下的`startup.sh`脚本即可启动`skywalking`服务
```bash
[root@localhost ~]# cd /usr/local/src
[root@localhost /usr/local/src]# wget http://mirrors.tuna.tsinghua.edu.cn/apache/skywalking/6.6.0/apache-skywalking-apm-6.6.0.tar.gz
[root@localhost /usr/local/src]# mkdir ../skywalking && tar -zxvf apache-skywalking-apm-6.6.0.tar.gz -C ../skywalking --strip-components 1
[root@localhost /usr/local/src]# cd ../skywalking/
[root@localhost /usr/local/skywalking]# ll -rh  # 解压后的目录文件如下
total 88K
drwxr-xr-x 2 root root   53 Dec 28 18:22 webapp
-rw-rw-r-- 1 1001 1002 2.0K Dec 24 14:10 README.txt
drwxrwxr-x 2 1001 1002  12K Dec 24 14:28 oap-libs
-rwxrwxr-x 1 1001 1002  32K Dec 24 14:10 NOTICE
drwxrwxr-x 3 1001 1002 4.0K Dec 28 18:22 licenses
-rwxrwxr-x 1 1001 1002  29K Dec 24 14:10 LICENSE
drwxr-xr-x 2 root root  221 Dec 28 18:22 config
drwxr-xr-x 2 root root  241 Dec 28 18:22 bin
drwxrwxr-x 8 1001 1002  143 Dec 24 14:21 agent
[root@localhost /usr/local/skywalking]# 
[root@localhost /usr/local/skywalking]# bin/startup.sh
SkyWalking OAP started successfully!
SkyWalking Web Application started successfully!
[root@localhost /usr/local/skywalking]#
```
> - SkyWalking控制台服务默认监听8080端口，若有防火墙需要开放该端口：
> - 若希望允许远程传输，则还需要开放11800（gRPC）和12800（rest）端口，远程agent将通过该端口传输收集的数据：
```bash
[root@localhost /usr/local/skywalking]# firewall-cmd --zone=public --add-port=8080/tcp --permanent
success
[root@localhost /usr/local/skywalking]# firewall-cmd --reload
success
[root@localhost /usr/local/skywalking]#
[root@localhost /usr/local/skywalking]# firewall-cmd --zone=public --add-port=11800/tcp --permanent
success
[root@localhost /usr/local/skywalking]# firewall-cmd --zone=public --add-port=12800/tcp --permanent
success
[root@localhost /usr/local/skywalking]# firewall-cmd --reload
success
[root@localhost /usr/local/skywalking]#
```

---
##### 1. 安装`docker`
```bash
sudo yum remove docker*
sudo yum install -y yum-utils

# 配置docker的yum地址
sudo yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装指定版本
sudo yum install -y docker-ce-20.10.8 docker-ce-cli-20.10.8 containerd.io-1.4.6

# 启动&开机启动docker
systemctl enable docker --now

# docker加速配置
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://82m9ar63.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

##### 2. 安装`docker-compose`
```bash
# 1.下载docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# 2.赋予执行权限
sudo chmod +x /usr/local/bin/docker-compose
# 3.建立软连接
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# 4.查看版本
docker-compose --version
```


### 二、镜像下载
> 注意：版本之间要匹配，skywalking可以使用多种存储。这里使用es7版本
```bash
docker pull apache/skywalking-oap-server:8.7.0-es7
docker pull apache/skywalking-ui:8.7.0
docker pull elasticsearch:7.14.0
```

#### - 镜像查询
[hub.docker](https://hub.docker.com/search?type=image)


### 三、修改系统参数
> `elasticsearch`需要修改一些系统参数才可以启动
```bash
[root@cm3gy /]# vi /etc/sysctl.conf
vm.max_map_count=262144
[root@cm3g /]# sysctl -p


[root@cm3g /]# vi/etc/systemd/system.conf
DefaultLimitNOFILE=65536
DefaultLimitNPROC=32000
DefaultLimitMEMLOCK=infinity
[root@cm3g /]# systemctl daemon-reload


[root@cm3g /]# vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
* hard memlock unlimited
* soft memlock unlimited
```

### 四、部署
#### 1. 部署`elasticsearch`
```bash
[root@cm3g /]# mkdir -p /home/elasticsearch/{config,data,logs}
[root@cm3g /]# chmod 777 /home/elasticsearch/*
[root@cm3g /]# echo "http.host: 0.0.0.0" >> /home/elasticsearch/config/elasticsearch.yml
[root@cm3g /]# cd /home/elasticsearch && vim build.sh
#!/bin/bash
  
docker stop elasticsearch && docker rm elasticsearch

docker run --name elasticsearch \
        --restart=always \
        -p 9200:9200 -p 9300:9300 \
        -e "discovery.type=single-node" \
        -e ES_JAVA_OPTS="-Xms512m -Xmx1024m" \
        -v /home/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
        -v /home/elasticsearch/data:/usr/share/elasticsearch/data \
        -v /home/elasticsearch/logs:/usr/share/elasticsearch/logs \
        -d elasticsearch:7.14.0
[root@cm3g /]# sh build.sh
[root@cm3g /]# docker logs -f elasticsearch
```

#### 2. 部署`skywalking-oap`与`skywalking-ui`
> - 这里注意 `SW_STORAGE=elasticsearch7`这里需要指定 `es7`版本。
> - `SW_OAP_ADDRESS=http://oap:12800`这里要加`http://`否则会找不到`oap`服务。
```bash
[root@cm3g /]# mkdir -p /home/skywalking
[root@cm3g /]# cd /home/skywalking && vim build.sh
#!/bin/bash
  
docker stop oap && docker rm oap
docker run --name oap \
        --restart=always -d \
        -e TZ=Asia/Shanghai \
        -p 12800:12800 \
        -p 11800:11800 \
        --link elasticsearch:elasticsearch \
        -e SW_STORAGE=elasticsearch7 \
        -e SW_STORAGE_ES_CLUSTER_NODES=elasticsearch:9200 \
        apache/skywalking-oap-server:8.7.0-es7


docker stop skywalking-ui && docker rm skywalking-ui
docker run --name skywalking-ui \
        --restart always -d \
        -e TZ=Asia/Shanghai \
        -p 8090:8080 \
        --link oap:oap \
        -e SW_OAP_ADDRESS=http://oap:12800 \
        apache/skywalking-ui:8.7.0
```

### 五、访问
> http://ip:8090

![](https://ae05.alicdn.com/kf/H39d5a316790548ebaeabc6ea0f9b401dq.png)

### 六、`Agent`项目集成
> - [skywalking-agent下载](https://archive.apache.org/dist/skywalking/)
> - 启动参数说明：
>   - `-javaagent:home/skywalking/agent/skywalking-agent.jar` agent的位置
>   - `-Dskywalking.agent.service_name=` 指定服务在`skywalking`的名称
>   - `-Dskywalking.agent.instance_name=` 指定配置实例名称
>   - `-Dskywalking.collector.backend_service=` 指定`skywalking`的`server`地址
```bash
[root@cm3g /]# cd /home/skywalking
[root@cm3g /]# wget https://archive.apache.org/dist/skywalking/8.7.0/apache-skywalking-apm-8.7.0.tar.gz
[root@cm3g /]# cp -r apache-skywalking-apm-bin/agent/ .
[root@cm3g /]# tar -zxvf apache-skywalking-apm-8.7.0.tar.gz
[root@cm3g /]# java -javaagent:home/skywalking/agent/skywalking-agent.jar -Dskywalking.agent.service_name=eureka-server -Dskywalking.collector.backend_service=192.168.x.130:11800 -Dskywalking.agent.instance_name=192.168.100.54@eureka-server -jar eureka-server.jar
```
![](https://ae05.alicdn.com/kf/H30a80f6439624f5999df39d415eb45e5j.png)

- 采样率设置
> 默认情况下，`skywalking`会采集所有追踪的数据轨迹。设置采样率并不会影响相关指标的计算（服务、实例、端点、拓扑图等还是使用完整的数据计算）。

- `config/application.yml`
> - 默认配置10000，采样率精确到1/10000，即10000 * 1/10000 = 1 = 100%。
> - 假设我们设计采样50%，那么设置为5000
```yml
receiver-trace:
  selector: ${SW_RECEIVER_TRACE:default}
  default:
    sampleRate: ${SW_TRACE_SAMPLE_RATE:5000}
```
- 建议
> 后算实例可以设置不同的采样率，但是官方建议设置为同样的值。

### 七、日志集成`TraceId`
- `pom.xml`
```xml
<!--logback-->
<dependency>
    <groupId>org.apache.skywalking</groupId>
    <artifactId>apm-toolkit-logback-1.x</artifactId>
    <version>8.7.0</version>
</dependency>
<!--log4j2-->
<dependency>
    <groupId>org.apache.skywalking</groupId>
    <artifactId>apm-toolkit-log4j-2.x</artifactId>
    <version>8.7.0</version>
</dependency>
```
- `logback-spring.xml`
```xml
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
        <!--加上skywalking的追踪id-->
        <layout class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.TraceIdPatternLogbackLayout">
            <Pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%tid] [%thread] %-5level %logger{36} -%msg%n</Pattern>
        </layout>
    </encoder>
</appender>

<!-- skywalking grpc 日志收集 8.4.0版本开始支持 -->
<appender name="grpc-log" class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.log.GRPCLogClientAppender">
<encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
    <layout class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.mdc.TraceIdMDCPatternLogbackLayout">
        <Pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%tid] [%thread] %-5level %logger{36} -%msg%n</Pattern>
    </layout>
</encoder>
</appender>

```

### 八、获取`TraceId`
> 通过`MDC`获取不到`traceId`，可以通过手动追踪`API`方式来获取
```xml
<dependency>
    <groupId>org.apache.skywalking</groupId>
    <artifactId>apm-toolkit-trace</artifactId>
    <version>8.7.0</version>
</dependency>
```
- 方式
```java
import org.apache.skywalking.apm.toolkit.trace.TraceContext;

String traceId = TraceContext.traceId();  
```

### 九、告警`WebHook`

- `alarm-settings.yml`配置`WebHook`
```yml
rules:
  # 规则唯一名称，必须以'_rule'结尾.
  service_resp_time_rule:
    # 度量名称，也是OAL脚本中的度量名，目前Service, Service Instance, Endpoint的度量可以用于告警
    metrics-name: service_resp_time
    # [可选]默认，匹配此指标中的所有服务
    include-names:
      - service_a
      - service_b
    exclude-names:
      - service_c
    # 阈值，对于多种指标值的如percentile可以配置P50、P75、P90、P95、P99的阈值
    threshold: 75
    # 操作符
    op: <
    # 评估度量标准的时间长度
    period: 10
    # 度量有多少次符合告警条件后，才会触发告警
    count: 3
    # 检查多少次，告警触发后保持沉默，默认周期相同
    silence-period: 10
    # 该规则触发时，发送的通知消息
    message: Response time of service {name} is more than 50ms in 1 minutes of last 1 minutes.

webhooks: 
  - http://ip:port/skyWalking/alarm
```

- `pom.xml`
```xml
<dependency>
    <groupId>com.aliyun</groupId>
    <artifactId>alibaba-dingtalk-service-sdk</artifactId>
    <version>1.0.1</version>
</dependency>

<dependency>
    <groupId>commons-codec</groupId>
    <artifactId>commons-codec</artifactId>
    <version>1.15</version>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.75</version>
</dependency>
```
- 代码
```java
@Data
public class AlarmMessageDTO implements Serializable {

    private int scopeId;
    private String scope;
    /**
     * Target scope entity name
     */
    private String name;
    private String id0;
    private String id1;
    private String ruleName;
    /**
     * Alarm text message
     */
    private String alarmMessage;
    /**
     * Alarm time measured in milliseconds
     */
    private long startTime;
    
    private List<Tag> tags;
    private transient int period;
    private transient boolean onlyAsCondition;

}
//------------------------ service --------------------------
@Slf4j
@Service
public class DingTalkAlarmService {

    @Value("${dingtalk.webhook}")
    private String webhook;
    @Value("${dingtalk.secret}")
    private String secret;

    public void sendMessage(String content) {
        try {
            Long timestamp = System.currentTimeMillis();
            String stringToSign = timestamp + "\n" + secret;
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes("UTF-8"), "HmacSHA256"));
            byte[] signData = mac.doFinal(stringToSign.getBytes("UTF-8"));
            String sign = URLEncoder.encode(new String(Base64.encodeBase64(signData)), "UTF-8");

            String serverUrl = webhook + "&timestamp=" + timestamp + "&sign=" + sign;
            
            DingTalkClient client = new DefaultDingTalkClient(serverUrl);
            OapiRobotSendRequest request = new OapiRobotSendRequest();
            request.setMsgtype("text");
            OapiRobotSendRequest.Text text = new OapiRobotSendRequest.Text();
            text.setContent(content);
            request.setText(text);
            client.execute(request);
            
        } catch (ApiException e) {
            e.printStackTrace();
            log.error(e.getMessage(), e);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            log.error(e.getMessage(), e);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            log.error(e.getMessage(), e);
        } catch (InvalidKeyException e) {
            e.printStackTrace();
            log.error(e.getMessage(), e);
        }
    }
}
//------------------------ controller --------------------------
@Slf4j
@RestController
@RequestMapping("/skywalking")
public class AlarmController {

    @Autowired
    private DingTalkAlarmService dingTalkAlarmService;

    @PostMapping("/alarm")
    public void alarm(@RequestBody List<AlarmMessageDTO> alarmMsgList) {
        log.info("收到告警信息: {}", JSON.toJSONString(alarmMsgList));
        if (null != alarmMsgList) {
            alarmMsgList.forEach(
                    e -> dingTalkAlarmService.sendMessage(
                            MessageFormat.format("-----来自SkyWalking的告警-----\n【名称】: {0}\n【消息】: {1}\n", 
                                    e.getName(), e.getAlarmMessage())));
        }
    }
}

```


### 十一、参考文档
* [基于docker部署skywalking实现全链路监控](https://www.jianshu.com/p/a237d6e810c6)
* [docker 安装 Skywalking](https://www.jianshu.com/p/cc16196df610)

* [SkyWalking UI指标使用说明(3)](https://lizz6.blog.csdn.net/article/details/107535100)
* [skywalking ui图表解释说明]()
* [SkyWalking8配置:忽略采集跟踪路径](https://lizz6.blog.csdn.net/article/details/108059238)

* [SkyWalking 8: 常见问题总结](https://my.oschina.net/osgit/blog/4558674)