# Minio
> - 目前可用于文件存储的网络服务有：`阿里云OSS、七牛云、腾讯云、华为云`等。但这些都是收费服务。而`FastDFS`运维复杂
> - `minio`是全球领先的对象存储先锋，在标准硬件上，读/写速度上高达`183GB/秒和171GB/秒`。

[官网](https://min.io/download#/docker)

- `Minio`与`FastDFS`对比优势
- - 安装部署复杂度：`Minio`支持
  - 文档齐全
  - 开源项目运营组织
  - 提供UI界面
  - 性能高
  - 支持容器化：可以与docker\k8s 等技术集成
  - 丰富的SDK
  
  
 ### 二、安装
 - `二进制`安装
 ```bash
 #!/bin/bash
 
 wget -P /opt/install https://dl.min.io/server/minio/release/linux-amd64/minio
 chmod +x /opt/install/minio
 
 export MINIO_ROOT_USER=admin
 export MINIO_ROOT_PASSWORD=minio
 nohup /opt/install/minio server /usr/local/minio/data --config-dir /usr/local/minio/config \
 --console-address :9001 --address :9000 >> /usr/local/minio/minio.log 2>&1 &
 ```