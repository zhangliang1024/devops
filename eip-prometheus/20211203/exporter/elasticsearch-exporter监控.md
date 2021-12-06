# prometheus实现elasticsearch监控

### 一、`docker`部署`elasticsearch`
```bash
docker run --name elasticsearch \
        --restart=always \
        -p 9200:9200 -p 9300:9300 \
        -e "discovery.type=single-node" \
        -e ES_JAVA_OPTS="-Xms512m -Xmx1024m" \
        -v /home/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
        -v /home/elasticsearch/data:/usr/share/elasticsearch/data \
        -v /home/elasticsearch/logs:/usr/share/elasticsearch/logs \
        -d elasticsearch:7.14.0
```


### 二、`docker`部署`elasticsearch-exporter`
```bash
docker run -d \
     --name es-exporter \
     --restart always \
    -p 9114:9114 \
    bitnami/elasticsearch-exporter \
    --es.uri "http://182.42.116.245:9200"
    
# ---------------------

docker logs -f es-exporter    
```

### 三、访问`Metrics`
> http://xxx.xx.xx.x:9114/metrics


### 四、`prometheus`配置
> prometheus.yml 文件
```ymal
- job_name: elasticsearch
  scrape_interval: 10s
  static_configs:
  - targets: ['182.xx.116.xx:9114']
```


### 五、使用模板
> 6483


### 六、参考文档
[elasticsearch-exporter部署手册](https://blog.csdn.net/qq_43021786/article/details/118764767)