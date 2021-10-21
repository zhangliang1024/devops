# Docker安装`Nginx`

### 一、下载`nginx`镜像
```bash
[root@zhangl ~]# docker search nginx
[root@zhangl ~]# docker pull nginx
[root@zhangl ~]# docker images|grep nginx
nginx                                latest    dd34e67e3371   8 days ago      133MB
[root@zhangl ~]# 
```

### 二、启动`nginx`容器实例
> 参数说明
```properties
   --rm : 容器终止运行后，自动删除容器文件
 --name : 指定运行容器名称
     -p : 端口映射
     -d : 容器启动后，在后台运行
```
```bash
[root@zhangl ~]# docker run --rm -d --name nginx -p 80:80 -p 443:443 nginx
358354f206fdbc5c20199a307392c11972b1bedab306144e5af56995edbb3e4b
[root@zhangl ~]# docker ps | grep nginx
```

### 三、访问`nginx`服务
> http://192.168.100.xx

### 四、使用自定义文件进行替换容器文件
> 文件规划
```properties
/usr/local/docker/nginx/html : 文件目录
/usr/local/docker/nginx/conf : 配置目录
/usr/local/docker/nginx/logs ：日志目录
/usr/local/docker/nginx/certs : ssl证书目录
```
> 进入容器：/etc/nginx目录，查看nginx.conf配置
```bash
[root@zhangl ~]# docker exec -it nginx /bin/bash
[root@zhangl ~]# cat /etc/nginx/nginx.conf
```
> 拷贝容器内Nginx配置文件到/usr/local/docker/nginx/conf目录
```bash
[root@zhangl ~]# docker cp nginx:/etc/nginx/nginx.conf /usr/local/docker/nginx/conf/
```


#### 1. `nginx.conf`配置文件
```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024; # 工作进程的最大连接数量
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # 日志格式设置
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```
> default.conf
```conf 
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
```
#### 2. 整理后`nginx.conf`
```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server {
            listen       80;
            listen  [::]:80;
            server_name *.fengwan1024.cn;
    
            #把http的域名请求转成https
            return 301 https://$host$request_uri;
	}
	
	server {
            #SSL 访问端口号为 443
            listen 443 ssl; 
            #填写绑定证书的域名 多个以空格分开
            server_name *.fengwan1024.cn; 
            #证书位置及文件名称 默认:/etc/nginx
            ssl_certificate 1_cloud.tencent.com_bundle.crt; 
            #私钥位置及文件名称
            ssl_certificate_key 2_cloud.tencent.com.key; 
            ssl_session_timeout 5m;
            #请按照以下协议配置
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2; 
            #请按照以下套件配置，配置加密套件，写法遵循 openssl 标准。
            ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; 
            ssl_prefer_server_ciphers on;
            location / {
                #网站主页路径。此路径仅供参考，具体请您按照实际目录操作。
                #root html; 
                #index  index.html index.htm;
                proxy_pass http://139.198.xx.xxx;
            }
    }
}
```

### 五、`docker`启动
> 参数说明
```properties
   --rm ：容器终止运行后，自动删除容器文件
 --name : 指定运行容器名称
     -d : 容器启动后，在后台运行
     -p : 端口映射 暴露80和443端口
     -v : 挂载宿主机目录到容器目录
     /usr/local/docker/nginx/html:/usr/share/nginx/html    将自己的文件目录挂载到容器/usr/share/nginx/html
     /usr/local/docker/nginx/logs:/var/log/nginx           将自己的log目录挂载到容器
     /usr/local/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf 将自己的配置nginx.conf挂载到容器
     /usr/local/docker/nginx/certs:/etc/nginx/crets    将自己的证书目录挂载到容器，在nginx.conf中指定
```
> 启动容器 restart.sh
```bash
#!/bin/bash

docker stop nginx && docker rm nginx

docker run -d --name nginx \
       -p 80:80 -p 443:443 \
       -v /usr/local/docker/nginx/html:/usr/share/nginx/html \
       -v /usr/local/docker/nginx/logs:/var/log/nginx \
       -v /usr/local/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
       -v /usr/local/docker/nginx/certs:/etc/nginx/certs \
       nginx
```
> 交互式启动
```bash
docker run -it --name nginx  -p 80:80 -p 443:443  -v /usr/local/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf    -v /usr/local/docker/nginx/certs:/etc/nginx/certs nginx /bin/bash
```
> docker-compose.yaml
```yaml
version: '3.1'
services:
  nginx:
    image: nginx:latest
    container_name: nginx
    restart: always
    ports:
      - 80:80
      - 443:443
    volumes:
      - /usr/local/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf
      - /usr/local/docker/nginx/logs:/var/log/nginx
      - /usr/local/docker/nginx/html:/usr/share/nginx/html
      - /usr/local/docker/nginx/certs:/etc/nginx/certs

```


### 六、二进制安装
#### 1. 安装依赖
```bash
yum -y install gcc zlib zlib-devel pcre-devel openssl openssl-devel
```
#### 2. [下载](http://nginx.org/download/)/安装
> 二进制安装默认目录: `/usr/local/nginx`
```bash
wget http://nginx.org/download/nginx-1.9.3.tar.gz
tar -zxvf nginx-1.9.3.tar.gz -C /usr/local/
cd /usr/local/nginx-1.9.3
./configure --prefix=/usr/local/nginx --with-http_ssl_module
make
make install
```
#### 3. 编辑配置文件
```bash
vim /usr/local/nginx/conf/nginx.conf
```
#### 4. `nginx`命令
```bash
启动nginx: ./sbin/nginx
停止nginx: ./sbin/nginx -s stop
重新加载 : ./sbin/nginx -s reload
查看安装模块： ./sbin/nginx -V  
```
> `./sbin/nginx -V  `查看安装模块
```properties
出现 configure arguments: --with-http_ssl_module, 则已安装
```


### 七、参考文档
* [Docker容器部署 Nginx服务](https://www.cnblogs.com/saneri/p/11799865.html)
* [docker安装nginx并配置SSL](https://blog.csdn.net/weixin_43909881/article/details/105634879)
* [Docker安装nginx以及配置nginx https域名](https://juejin.cn/post/6844904112413229069)
---
* [Nginx 配置 HTTPS 完整过程](https://blog.csdn.net/weixin_37264997/article/details/84525444)
* [LINUX安装nginx详细步骤](https://blog.csdn.net/t8116189520/article/details/81909574)
* [Nginx 服务器 SSL 证书安装部署](https://cloud.tencent.com/document/product/400/35244)
---
* [一台nginx服务器多域名配置的方法](https://www.jb51.net/article/140826.htm)