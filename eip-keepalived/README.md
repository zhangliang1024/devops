# Keepalived+Haporxy高可用

### 搭建`keepalived`
```shell
yum install -y conntrack-tools libseccomp libtool-ltdl psmisc
yum install -y keepalived
```
- `keepalived`配置
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
        #指定虚拟IP
        192.168.1.56 
    }
    track_script {
        check_haproxy
    }

}
EOF
```
- 启动服务
```shell
systemctl start keepalived.service
systemctl enable keepalived.service
```

### 安装`haproxy`
- 准备工作
> 选择临时或永久
```shell
sed -i 's/enforcing/disabled/' /etc/selinux/config  # 永久
setenforce 0  # 临时
```
- 安装
```shell
yum install -y haproxy
```
- `haproxy`配置
```shell
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
    bind                 *:18848
    option               httplog
    default_backend      nacos-backend 

backend nacos-backend
    mode        http
    balance     roundrobin
    server      192.168.1.53   192.168.1.53:8848 check
    server      192.168.1.54   192.168.1.54:8848 check
    server      192.168.1.55   192.168.1.55:8848 check
    # 虚拟ip    指向的服务ip
listen stats
    bind                 *:1080
    stats auth           admin:awesomePassword
    stats refresh        5s
    stats realm          HAProxy\ Statistics
    stats uri            /admin?stats
EOF
```
- 启动`haproxy`
```shell
systemctl start haproxy
systemctl enable haproxy
```
- 查看服务
```shell
netstat -lntup|grep haproxy
```


### 参考文档
[Nacos高可用集群搭建](https://www.cnblogs.com/wwjj4811/p/14610307.html)