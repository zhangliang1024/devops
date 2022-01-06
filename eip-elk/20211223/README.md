

### 1.镜像版本
```bash
docker pull elasticearch:7.14.0
docker pull elastic/filebeat:7.14.0
docker pull elastic/logstash:7.14.0
docker pull kibana:7.14.0
```


### 2. 部署`elasticsearch`
```bash
docker run --name es -d \
    -p 9200:9200 -p 9300:9300 \
    -e "discovery.type=single-node" \
    --net elk-net  \
    elasticsearch:7.14.0
```

### 3. 部署`kibana`
- `kibana.yml`
> - 汉化支持：`i18n.locale: "zh-CN"`
```bash
server.host: "0"
server.shutdownTimeout: "5s"
elasticsearch.hosts: [ "http://你的ip:9200" ]
monitoring.ui.container.elasticsearch.enabled: true
i18n.locale: "zh-CN"
```
- 部署
```bash
docker run --name kibana -d \
    -v /home/docker/elk/kibana:/config \
    -p 5601:5601 \
    --net elk-net \
    kibana:7.14.0
```

### 4. 部署`logstash`
- `logstash.yml`
```bash
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: elasticsearch机器的ip:9200
```
- `logstash.conf`
```bash
input {
  beats {
    port => 4567
  }
}
filter {
  #Only matched data are send to output.
}
output {
  elasticsearch {
    hosts  => ["http://elasticsearch机器ip:9200"]   #ElasticSearch host, can be array.
    index  => "logapp-%{+YYYY.MM}"         #The index to write data to.
  }
}
```
- `logstash.conf参考`
```bash
## multiline 插件也可以用于其他类似的堆栈式信息，比如 linux 的内核日志。
input {
  kafka {
    ## app-log-服务名称
    topics_pattern => "app-log-.*"
    bootstrap_servers => "192.168.11.51:9092"
    codec => json
    consumer_threads => 1 ## 增加consumer的并行消费线程数
    decorate_events => true
    #auto_offset_rest => "latest"
    group_id => "app-log-group"
 }
   
   kafka {
    ## error-log-服务名称
    topics_pattern => "error-log-.*"
    bootstrap_servers => "192.168.11.51:9092"
    codec => json
    consumer_threads => 1
    decorate_events => true
    #auto_offset_rest => "latest"
    group_id => "error-log-group"
   }
   
}

filter {
  
  ## 时区转换
  ruby {
  code => "event.set('index_time',event.timestamp.time.localtime.strftime('%Y.%m.%d'))"
  }

  if "app-log" in [fields][logtopic]{
    grok {
        ## 表达式,这里对应的是Springboot输出的日志格式
        match => ["message", "\[%{NOTSPACE:currentDateTime}\] \[%{NOTSPACE:level}\] \[%{NOTSPACE:thread-id}\] \[%{NOTSPACE:class}\] \[%{DATA:hostName}\] \[%{DATA:ip}\] \[%{DATA:applicationName}\] \[%{DATA:location}\] \[%{DATA:messageInfo}\] ## (\'\'|%{QUOTEDSTRING:throwable})"]
    }
  }

  if "error-log" in [fields][logtopic]{
    grok {
        ## 表达式
        match => ["message", "\[%{NOTSPACE:currentDateTime}\] \[%{NOTSPACE:level}\] \[%{NOTSPACE:thread-id}\] \[%{NOTSPACE:class}\] \[%{DATA:hostName}\] \[%{DATA:ip}\] \[%{DATA:applicationName}\] \[%{DATA:location}\] \[%{DATA:messageInfo}\] ## (\'\'|%{QUOTEDSTRING:throwable})"]
    }
  }
  
}

## 测试输出到控制台：
output {
  stdout { codec => rubydebug }
}


## elasticsearch：
output {

  if "app-log" in [fields][logtopic]{
 ## es插件
 elasticsearch {
       # es服务地址
        hosts => ["192.168.11.35:9200"]
        # 用户名密码      
        user => "elastic"
        password => "123456"
        ## 索引名，+ 号开头的，就会自动认为后面是时间格式：
        ## javalog-app-service-2019.01.23 
        index => "app-log-%{[fields][logbiz]}-%{index_time}"
        # 是否嗅探集群ip：一般设置true；http://192.168.11.35:9200/_nodes/http?pretty
        # 通过嗅探机制进行es集群负载均衡发日志消息
        sniffing => true
        # logstash默认自带一个mapping模板，进行模板覆盖
        template_overwrite => true
    } 
  }
  
  if "error-log" in [fields][logtopic]{
  elasticsearch {
        hosts => ["192.168.11.35:9200"]    
        user => "elastic"
        password => "123456"
        index => "error-log-%{[fields][logbiz]}-%{index_time}"
        sniffing => true
        template_overwrite => true
    } 
  }
}
```


- 部署
```bash
docker run --name logstash -d \
    -p 4567:4567 -p 5044:5044 -p 5045:5045 \
    -v /home/docker/elk/logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
    -v /home/docker/elk/logstash/logstash.yml:/usr/share/logstash/config/logstash.yml \
    --net elk-net \
    logstash:7.14.0
```


### 5. 部署`filebeat`
- `filebeat.yml`
```bash
filebeat.inputs:
- type: log
  paths:
    - /var/log/logapp/app.info.log
    
output.logstash:
    hosts: ["logstash的ip:4567"]
```
- 部署
```bash
docker run --name filebeat -d \
    -u root \
    -v /var/log/logapp:/var/log/logapp:rw \
    -v /home/docker/elk/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro \
    -e setup.kibana.host=你的kibana机器的ip:5601 \
    --net elk-net \
    docker.elastic.co/beats/filebeat:7.14.0
```