# konw streaming
> `knos streaming` 是一套云原生的 `kafka`管理平台。

### `docker` 部署
```yml
version: "2"
services:
  # *不要调整knowstreaming-manager服务名称，ui中会用到
  knowstreaming-manager:
    image: knowstreaming/knowstreaming-manager:latest
    container_name: knowstreaming-manager
    privileged: true
    restart: always
    depends_on:
      - elasticsearch-single
      - knowstreaming-mysql
    expose:
      - 80
    command:
      - /bin/sh
      - /ks-start.sh
    environment:
      TZ: Asia/Shanghai
      # mysql服务地址
      SERVER_MYSQL_ADDRESS: knowstreaming-mysql:3306
      # mysql数据库名
      SERVER_MYSQL_DB: know_streaming
      # mysql用户名
      SERVER_MYSQL_USER: root
      # mysql用户密码
      SERVER_MYSQL_PASSWORD: admin2022_
      # es服务地址
      SERVER_ES_ADDRESS: elasticsearch-single:9200
      # 服务JVM参数
      JAVA_OPTS: -Xmx1g -Xms1g
      # 对于kafka中ADVERTISED_LISTENERS填写的hostname可以通过该方式完成
#    extra_hosts:
#      - "hostname:x.x.x.x"
      # 服务日志路径
#    volumes:
#      - /ks/manage/log:/logs
  knowstreaming-ui:
    image: knowstreaming/knowstreaming-ui:latest
    container_name: knowstreaming-ui
    restart: always
    ports:
      - '80:80'
    environment:
      TZ: Asia/Shanghai
    depends_on:
      - knowstreaming-manager
#    extra_hosts:
#      - "hostname:x.x.x.x"
  elasticsearch-single:
    image: docker.io/library/elasticsearch:7.6.2
    container_name: elasticsearch-single
    restart: always
    expose:
      - 9200
      - 9300
#    ports:
#      - '9200:9200'
#      - '9300:9300'
    environment:
      TZ: Asia/Shanghai
      # es的JVM参数
      ES_JAVA_OPTS: -Xms512m -Xmx512m
      # 单节点配置，多节点集群参考 https://www.elastic.co/guide/en/elasticsearch/reference/7.6/docker.html#docker-compose-file
      discovery.type: single-node
      # 数据持久化路径
#    volumes:
#      - /ks/es/data:/usr/share/elasticsearch/data

  # es初始化服务，与manager使用同一镜像
  # 首次启动es需初始化模版和索引,后续会自动创建
  knowstreaming-init:
    image: knowstreaming/knowstreaming-manager:latest
    container_name: knowstreaming-init
    depends_on:
      - elasticsearch-single
    command:
      - /bin/bash
      - /es_template_create.sh
    environment:
      TZ: Asia/Shanghai
      # es服务地址
      SERVER_ES_ADDRESS: elasticsearch-single:9200

  knowstreaming-mysql:
    image: knowstreaming/knowstreaming-mysql:latest
    container_name: knowstreaming-mysql
    restart: always
    environment:
      TZ: Asia/Shanghai
      # root 用户密码
      MYSQL_ROOT_PASSWORD: admin2022_
      # 初始化时创建的数据库名称
      MYSQL_DATABASE: know_streaming
      # 通配所有host,可以访问远程
      MYSQL_ROOT_HOST: '%'
    expose:
      - 3306
#    ports:
#      - '3306:3306'
      # 数据持久化路径
#    volumes:
#      - /ks/mysql/data:/data/mysql
```



### 七、参考文档
[docker部署knowstreaming](https://github.com/didi/KnowStreaming/blob/master/docs/install_guide/%E5%8D%95%E6%9C%BA%E9%83%A8%E7%BD%B2%E6%89%8B%E5%86%8C.md)