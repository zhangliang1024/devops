# 在后面加 -d 为在后台启动
# compose启动失败可以尝试手动启动Containers

docker-compose up --scale redis-sentinel=4
