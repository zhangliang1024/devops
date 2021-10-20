# Docker安装`harbor`

### 一、资源准备
> 安装`docker`\`docker-compose` harbor使用`docker-compse`维护
```properties
[root@zhangl local]# docker --version
[root@zhangl local]# docker-compose --version
```

### 二、`harbor`准备
#### 1.安装包[下载](https://github.com/goharbor/harbor/releases)
```bash
[root@zhangl local]# wget https://github.com/goharbor/harbor/releases/download/v2.3.2/harbor-online-installer-v2.3.2.tgz
[root@zhangl local]# tar -zxvf harbor-online-installer-v2.3.2.tgz -C /usr/local/harbor
[root@zhangl local]# cd /usr/local/harbor
[root@zhangl harbor]# cp harbor.yml harbor.yml.bak
```
#### 2.修改配置文件(配置对harbor的https访问)
>  vim harbor.yml
```yml
hostname: xxx.61.41.102
https:
  port: 443
  certificate: /usr/local/harbor/cert/xxx.61.41.102.crt
  private_key: /usr/local/harbor/cert/xxx.61.41.102.key
# harbor管理页面admin用户的密码
harbor_admin_password: admin123
```
#### 3.生成机构颁发证书
1. 生成CA证书私钥
```bash
openssl genrsa -out ca.key 4096
```
2. 生成CA证书
```bash
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=chinda/OU=chinda/CN=xxx.61.41.102" \
 -key ca.key \
 -out ca.crt
```
#### 4.生成服务器证书
> 证书通常包含一个`.crt`文件和`.key`文件

1.生成私钥
```bash
openssl genrsa -out xxx.61.41.102.key 4096
```
2.生成证书签名(CSR)
```bash
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=chinda/OU=chinda/CN=xxx.61.41.102" \
    -key xxx.61.41.102.key \
    -out xxx.61.41.102.csr
```
3.生成x509 v3扩展文件
```bash
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=xxx.61.41.102
DNS.2=xxx.61.41.102
DNS.3=harbor
EOF
```
4.使用v3.ext文件为Harbor主机生成证书
> 将xxx.61.41.102 CRS和CRT文件名中的替换为Harbor主机名。
```bash
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in xxx.61.41.102.csr \
    -out xxx.61.41.102.crt
```

#### 5.提供证书给Harbor和Docker
> 生成ca.crt，chinda.com.crt和chinda.com.key文件后，必须将它们提供给Harbor和Docker和重新配置使用它们的Harbor

1.创建存放他们的文件夹,将服务器证书和密钥复制到Harbor主机的cert文件夹中
```bash
cp xxx.61.41.102.crt /usr/local/harbor/cert/
cp xxx.61.41.102.key /usr/local/harbor/cert/
chmod a+x /usr/local/harbor/cert/
```
2.转换xxx.61.41.102.crt为xxx.61.41.102.cert，供Docker使用
> Docker守护程序将.crt文件解释为CA证书，并将.cert文件解释为客户端证书
```bash
openssl x509 -inform PEM -in xxx.61.41.102.crt -out xxx.61.41.102.cert
```
3.将服务器证书，密钥和CA文件复制到Harbor主机上的Docker 证书文件夹中
``` bash
mkdir /etc/docker/certs.d/xxx.61.41.102
cp xxx.61.41.102.cert /etc/docker/certs.d/xxx.61.41.102/
cp xxx.61.41.102.key /etc/docker/certs.d/xxx.61.41.102/
cp xxx.61.41.102.crt /etc/docker/certs.d/xxx.61.41.102/

ls /etc/docker/certs.d/xxx.61.41.102/
```
4.重启Docker引擎
```bash
systemctl restart docker
```

### 三、运行安装脚本
```bash
[root@zhangl ~]# cd /usr/local/harbor
[root@zhangl harbor]# ./install.sh
```

### 四、验证
> - http://xxx.61.41.102
> - 服务器登录验证 
```bash
[root@zhangl harbor]# docker login https://xxx.61.41.102 -u admin
```
> - 推送镜像
```bash
[root@zhangl harbor]# docker tag openjdk:latest xxx.61.41.102/library/openjdk:v1
[root@zhangl harbor]# docker images
[root@zhangl harbor]# docker push xxx.61.41.102/library/openjdk:v1
```
> - `compose`操作
```bash
# 查看执行状态
[root@zhangl harbor]# docker-compose ps
# 停止、移除存在的实例
[root@zhangl harbor]# docker-compose down -v
# 重启harbor
[root@zhangl harbor]# docker-compose up -d 
```


### 五、修改`docker`的配置文件`daemon.json`
> 若没有配置`https`访问方式，则需要在`daemon.json中`添加`insecure-registries`私库的服务地址。因为`Harbor默认使用http`，`docker默认使用https`的原因。我们可以`强制docker使用http`
```bash
[root@topcheer ~]# cat /etc/docker/daemon.json
{
  "log-driver":"json-file",
  "log-opts": {"max-size":"100m","max-file":"1"},
  "insecure-registries":["xxx.61.41.102"],
  "registry-mirrors":["https://d8b3zdiw.mirror.aliyuncs.com"]
}
[root@topcheer ~]# sudo systemctl daemon-reload
[root@topcheer ~]# sudo systemctl restart docker.service
```


### 五、问题
> Error response from daemon: Get https://192.168.102.95/v2/: dial tcp 192.168.102.95:443: connect: co
* [](https://blog.csdn.net/h111121111111/article/details/113994476)

### 六、参考文档
* ★★★ [Docker镜像仓库Harbor搭建](https://www.cnblogs.com/chinda/p/12776675.html)
* ★★ [企业级Docker Registry Harbor搭建和使用](https://www.cnblogs.com/zhaojiankai/p/7822135.html)

* [Harbor密码重置 密码修改 admin密码重置](https://www.cnblogs.com/dalianpai/p/11795826.html)
* [docker登录私仓失败:because it doesn‘t contain any IP SANs](https://blog.csdn.net/qq_37377136/article/details/107995620)























