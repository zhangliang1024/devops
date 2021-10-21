# Docker部署ELK


## 问题

### 1. 系统内存不足导致启动失败
```text
Native memory allocation (mmap) failed to map 2060255232 bytes for committing reserved memory
```
> 指定使用内存大小
```bash
# 1. 指定使用内存大小
docker run -p 9200:9200 -e ES_JAVA_OPTS="-Xms512m -Xmx512m"

# 2. compose方式，配置环境变量
environment:
      ES_JAVA_OPTS: "-Xms512m -Xmx512m"
```
