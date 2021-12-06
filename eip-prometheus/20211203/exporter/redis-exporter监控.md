# prometheus实现redis监控

### 一、`docker`部署`redis`
```bash
docker run -d --name redis \
    --restart always \
    -p 6379:6379 \
    -v /home/redis/data:/data \
    redis redis-server /etc/redis/redis.conf \
    --requirepass "123456" --appendonly yes
```


### 二、`docker`部署`redis-exporter`
```bash
docker run -d\
    --name redis_exporter \
    --restart always \
    -p 9121:9121 \
    oliver006/redis_exporter \
    --redis.addr redis://182.42.116.245:6379 \
    --redis.password 123456  
# ---------------------

docker logs -f redis_exporter
```

### 三、访问`Metrics`
> http://xxx.xx.xx.x:9121/metrics


### 四、`prometheus`配置
> prometheus.yml 文件
```ymal
- job_name: redis
  scrape_interval: 10s
  static_configs:
  - targets: ['182.xx.116.xxx:9121']
```


### 五、使用模板
> 11835


### 六、参考文档
[redis-exporter部署手册](https://blog.csdn.net/qq_43021786/article/details/118800559)