# Keepalived+Haporxy高可用

### 一、搭建`keepalived`
```shell
yum install -y conntrack-tools libseccomp libtool-ltdl psmisc
yum install -y keepalived
```
- `keepalived`配置
```shell
cat > /etc/keepalived/keepalived.conf <<EOF 
! Configuration File for keepalived

# 全局段
global_defs {
   router_id k8s # 只是名字
}

# VRRP 路由冗余协议
vrrp_instance VI_1 {                # 定义一个VRRP实例并设定名称
    state MASTER                    # 节点状态 MASTER BACKUP
    interface ens192                # 网络接口
    virtual_router_id 51            # 虚拟路由ID 0~255 ID相同表示同一个虚拟路由 MASTER和BACKUP配置相同ID
    priority 250                    # 初始权重 1~254 值越大优先级越高。在同一个VRRP实例中，MASTER节点高于BACKUP节点
    advert_int 1                    # 同步通知间隔，单位秒。MASTER和BACKUP之间通信检查时间间隔
    authentication {                # 认证配置，用于同一个VRRP实例MASTER和BACKUP之间通信
        auth_type PASS              # 认证类型 PASS\AH PASS为认证密码 
        auth_pass ceb1b3ec013d66163d6ab
    }
    virtual_ipaddress {             # VIP绑定 到 interface网络接口上
        192.168.1.56                # 指定虚拟VIP，可配置多个
    }
    track_script {                  # 配置检查脚本
        check_haproxy
    }
}

# 脚本段定义
vrrp_script check_haproxy {          # 用于检查haproxy是否正常
    script "killall -0 haproxy"      # 执行检查脚本
    interval 3                       # 每3秒检查一次
    weight -2                        # 权重
    fall 10                          # 认定结果为失败时的执行失败次数
    rise 2                           # 认定结果为成功时的执行成功次数
}

EOF
```
- 启动服务
```shell
systemctl start keepalived.service
systemctl enable keepalived.service
```

### 二、安装`haproxy`
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
    log         127.0.0.1 local2     # 全局日志 
    
    chroot      /var/lib/haproxy     # 设置Haproxy工作目录
    pidfile     /var/run/haproxy.pid # 设置haproxy的PID文件位置
    maxconn     4000                 # 设置每个haproxy进程可用最大连接数
    user        haproxy              # 用户
    group       haproxy              # 用户组
    daemon                           # 以后台形式运行haproxy
    nbproc      2                    # 工作进程数 cpu内核是几就写几 lscpu查看      
        
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------  
defaults
    mode                    http              # 工作模式 http 
    log                     global            # 日志输出方式，global表示使用全局段log的配置
    option                  httplog           # 记录HTTP详细日志
    option                  dontlognull       # 日志中不记录空连接
    option http-server-close                  # 表示每次请求完后主动关闭HTTP通道
    option forwardfor       except 127.0.0.0/8 # 表示应用程序想记录发起请求的客户端IP地址
    option                  redispatch        # 服务不可用后重定向其它健康服务器
    retries                 3                 # 健康检查 重试3次连接失败就认为服务不可用。通过后面check检查
    timeout http-request    10s               # http请求超时时长
    timeout queue           1m                # 一个请求在队列里的超时时间
    timeout connect         10s               # HA服务器与后端服务器连接超时时间 单位ms
    timeout client          1m                # 客户端超时
    timeout server          1m                # 后端服务超时
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000              # 

frontend nacos_fontend                        # 配置一组前端服务并启动监听
    mode                 http                 # 工作模式
    bind                 *:18848              # 监听IP和端口
    option               httplog              # 日志类别 http 日志格式
    default_backend      nacos-backend        # 使用的服务器组

backend nacos-backend                         # 服务器组
    mode        http
    balance     roundrobin                    # 负载均衡方式
    server      192.168.1.53   192.168.1.53:8848 check
    server      192.168.1.54   192.168.1.54:8848 check
    server      192.168.1.55   192.168.1.55:8848 check
    # 虚拟ip    指向的服务ip
listen stats
    bind                 *:1080
    mode                 http
    stats auth           admin:awesomePassword # 用户认证
    stats refresh        5s
    stats realm          HAProxy\ Statistics
    stats uri            /admin?stats          # 使用浏览器查看服务器状态端点
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

- 检查脚本
> `check_apiserver.sh`
```shell
vim /etc/keepalived/check_apiserver.sh
#!/bin/bash
err=0
for k in $(seq 1 5)
do
    check_code=$(pgrep haproxy)
    if [[ $check_code == "" ]]; then
        err=$(expr $err + 1)
        sleep 5
        continue
    else
        err=0
        break
    fi
done
if [[ $err != "0" ]]; then
    echo "systemctl stop keepalived"
    /usr/bin/systemctl stop keepalived
    exit 1
else
    exit 0
fi
```

### 五、参考文档
[Nacos高可用集群搭建](https://www.cnblogs.com/wwjj4811/p/14610307.html)

[k8s高可用部署keepalived + haproxy](https://www.jianshu.com/p/7cd9fab92fa1)

[Keepalived+HAProxy高可用集群K8S实现](https://www.jb51.net/article/241426.htm)

[keepalived实现haproxy高可用](https://blog.csdn.net/m0_53765226/article/details/127242181)

[Keepalived+HAProxy 搭建高可用负载均衡](https://xie.infoq.cn/article/0de8743541a595a46efc5c254)

[]()

[]()