

### `Nacos`集群部署
- 版本
```properties
Nacos: nacos/nacos-server:latest
Mysql: nacos/nacos-mysql:5.7
```

### 启动
```shell
[root@r9us45kbhkhg7v58 nacos]# cd /opt/nacos
[root@r9us45kbhkhg7v58 nacos]# ls
build.sh  docker-compose.yml
[root@r9us45kbhkhg7v58 nacos]# 
[root@r9us45kbhkhg7v58 nacos]# docker-compose up -d
[+] Running 5/5
 ⠿ Network nacos_skywalking_networks  Created                                                                                                                                 0.1s
 ⠿ Container nacos-sql                Started                                                                                                                                 0.6s
 ⠿ Container nacos03                  Started                                                                                                                                 1.7s
 ⠿ Container nacos01                  Started                                                                                                                                 1.7s
 ⠿ Container nacos02                  Started                                                                                                                                 1.7s
[root@r9us45kbhkhg7v58 nacos]# docker logs -f nacos01
```

```shell
cat > /etc/keepalived/keepalived.conf <<EOF 
! Configuration File for keepalived

global_defs {
   router_id k8s
}

vrrp_script check_haproxy {
    script "killall -0 haproxy"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER 
    interface ens192 
    virtual_router_id 51
    priority 250
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass ceb1b3ec013d66163d6ab
    }
    virtual_ipaddress {
        192.168.1.56
    }
    track_script {
        check_haproxy
    }

}
EOF

```

systemctl start keepalived.service
systemctl enable keepalived.service


sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时
yum install -y haproxy

cat > /etc/haproxy/haproxy.cfg << EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
# to have these messages end up in /var/log/haproxy.log you will
# need to:
# 1) configure syslog to accept network log events.  This is done
#    by adding the '-r' option to the SYSLOGD_OPTIONS in
#    /etc/sysconfig/syslog
# 2) configure local2 events to go to the /var/log/haproxy.log
#   file. A line like the following can be added to
#   /etc/sysconfig/syslog
#
#    local2.*                       /var/log/haproxy.log
#
log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon 
       
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------  
defaults
mode                    http
log                     global
option                  httplog
option                  dontlognull
option http-server-close
option forwardfor       except 127.0.0.0/8
option                  redispatch
retries                 3
timeout http-request    10s
timeout queue           1m
timeout connect         10s
timeout client          1m
timeout server          1m
timeout http-keep-alive 10s
timeout check           10s
maxconn                 3000

frontend nacos_fontend
mode                 http
bind                 *:8888
option               httplog
default_backend      nacos-backend

backend nacos-backend
mode        http
balance     roundrobin
server      140.246.154.99   140.246.154.99:8847 check
server      140.246.154.99   140.246.154.99:8849 check
server      140.246.154.99   140.246.154.99:8850 check

listen stats
bind                 *:1080
stats auth           admin:awesomePassword
stats refresh        5s
stats realm          HAProxy\ Statistics
stats uri            /admin?stats
EOF

systemctl enable haproxy
systemctl start haproxy
netstat -lntup|grep haproxy
