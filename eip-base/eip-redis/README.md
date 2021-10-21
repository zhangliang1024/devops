# `Dockcer`安装`Redis`

### 一、下载镜像
```bash
docker pull redis
```
- 查看镜像
```bash
docker images|grep redis
```

### 二、创建`Redis`容器
> redis容器中不存在redis.conf配置文件，挂载时需要在物理机中创建出redis.conf文件，映射入容器
- 创建`redis.conf`配置文件
```bash
mkdir -p /toony/redis/conf
touch /toony/redis/conf/redis.conf
```
- 创建容器
```bash
docker run -p 6379:6379 --name redis \
-v /toony/redis/data:/data \
-v /toony/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf
```
- 说明
```properties
-p 6379:6379：将容器的6379端口映射到宿主机6379端口
-v /toony/redis/data:/data：将数据挂载到宿主机
-v /toony/redis/conf/redis.conf:/etc/redis/redis.conf：将配置挂载到宿主机
-d redis redis-server /etc/redis/redis.conf：后台运行容器并加载配置文件
```
- `docker-compose.yml`
```bash
version: '3'
services:
  redis:
    container_name: redis
    image: redis
    ports:
      - "6379:6379"
    volumes:
      - /toony/redis/data:/data
      - /toony/redis/conf/redis.conf:/etc/redis/redis.conf
      - /mydata/mysql/conf:/etc/mysql
    restart: always
    command: redis-server /etc/redis/redis.conf
    environment:
      - COMPOSE_PROJECT_NAME=redis-server
```

### 三、修改配置文件
```bash
cd /mydata/redis/conf/

# 配置数据持久化
cat > redis.conf <<-EOF
appendonly yes
EOF
```

四、操作容器
- 查看容器
```bash
docker ps | grep redis
```
- 运行redis客户端
```bash
docker exec -it redis redis-cli
```
- 配置容器自启动
```bash
docker update redis --restart=always
```

### 五、参考博客
* [Docker安装Redis](https://www.cnblogs.com/chinda/p/13068405.html)