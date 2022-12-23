###

### 创建用户
> 创建Elasticsearch启动用户，并设置权限
```shell
groupadd elastic
useradd elastic -g elastic -p elasticsearch
chown -R elsearch:elsearch elasticsearch-7.2.0
```
> 切换用户
```shell
su elastic
```

