





> restart.sh
```bash
#!/bin/bash

docker stop jenkins && docker rm jenkins

docker run -d --name jenkins \
        -u root \
        -p 8080:8080 -p 5000:5000 \
        -v /toony/jenkins/jenkins_home:/var/jenkins_home \
        -v /toony/jenkins/jenkinsci:/usr/jenkinsci \
        -v /usr/bin/docker:/usr/bin/docker \
        -v /var/run/docker.sock:/var/run/docker.sock \
        jenkinsci/blueocean

```
> docker-compose.yml
```bash
cat > docker-compose.yml <<-EOF
version: '3'
services:                                     
  docker_jenkins:
    user: root                                
    restart: always                           
    image: jenkins/jenkins:lts                
    container_name: jenkins                   
    ports:                                    
      - 8080:8080
      - 50000:50000
    volumes:                                   
      - /toony/jenkins/jenkins_home:/var/jenkins_home 
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker               
      - /usr/local/bin/docker-compose:/usr/local/bin/docker-compose
  docker_nginx:
    restart: always
    image: nginx
    container_name: nginx
    ports:
      - 8090:80
      - 80:80
      - 433:433
    volumes:
      - /toony/nginx/conf.d/:/etc/nginx/conf.d
      - /toony/webserver/static/jenkins/dist/dist:/usr/share/nginx/html
EOF	  
```

### 问题
- mvn 没安装

### 参考博客
* [jenkins jenkinsci/blueocean 使用](https://blog.csdn.net/qq_21816375/article/details/80785162)
* [docker安装jenkinsci/blueocean并且创建pipeline项目](https://blog.csdn.net/fuck487/article/details/81872182)
* []()
* []()
* []()
* []()