

```bash
docker run -d --name mysql \
    -p 3306:3306 \
    --restart always \
    -v /opt/mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=123456 \
    --privileged=true \
    mysql:5.7
```