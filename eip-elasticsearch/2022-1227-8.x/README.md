# `es8`安全配置


### 一、`es8`安全通信证书 
> 使用自签证书，生成集群内部 `(transport)` 安全通信证书
- 生产 `ca` 证书
```shell
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]#./bin/elasticsearch-certutil ca
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ls
LICENSE.txt  NOTICE.txt  README.asciidoc  bin  config  data  elastic-stack-ca.p12  jdk  lib  logs  modules  plugins
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]#
```
默认 `ca` 文件名为 `elastic-stack-ca.p12` ，同时可以输入 `ca` 密码 `[123456]`
- 生产节点通信证书
```shell
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
...
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ls
LICENSE.txt  NOTICE.txt  README.asciidoc  bin  config  data  elastic-certificates.p12  elastic-stack-ca.p12  jdk  lib  logs  modules  plugins
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]#
```
默认证书文件名为 `elastic-certificates.p12` ，同时输入证书密码 `[12345678]`；将此证书放到各节点 `config/certs` 目录下


- 所有节点设置节点通信密码
```shell
./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

- 查看节点通信密码
```shell
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ./bin/elasticsearch-keystore show xpack.security.transport.ssl.keystore.secure_password
warning: ignoring JAVA_HOME=/usr/local/jdk-8; using bundled JDK
BYd_CPJjSTmJbIhS0OPW1g
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ./bin/elasticsearch-keystore show xpack.security.transport.ssl.truststore.secure_password
warning: ignoring JAVA_HOME=/usr/local/jdk-8; using bundled JDK
BYd_CPJjSTmJbIhS0OPW1g
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]#
```

- `es8`配置文件
> `elasticsearch.yml`
```yml
# ...
# Enable security features
xpack.security.enabled: true

xpack.security.enrollment.enabled: true

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

# Enable encryption and mutual authentication between cluster nodes
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/elastic-certificates.p12
  truststore.path: certs/elastic-certificates.p12
```

### 二、`es8`通信证书转换为`jks`格式
> p12(PKCS12)和JKS互换
```shell
# p12->jks
keytool -importkeystore -srckeystore keystore.p12 -srcstoretype PKCS12 -deststoretype JKS -destkeystore keystore.jks
# jks->p12
keytool -importkeystore -srckeystore keystore.jks -srcstoretype JKS -deststoretype PKCS12 -destkeystore keystore.p12
```

> `skywalking` 使用 `es` 做存储时，若 `es` 做了加密传输，需要 `jks` 证书。
```shell
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# keytool -importkeystore -srckeystore elastic-certificates.p12 -srcstoretype PKCS12 -deststoretype JKS -destkeystore keystore.jks
Importing keystore elastic-certificates.p12 to keystore.jks...
Enter destination keystore password:  
Re-enter new password: 
Enter source keystore password:  
Entry for alias instance successfully imported.
Entry for alias ca successfully imported.
Import command completed:  2 entries successfully imported, 0 entries failed or cancelled

Warning:
The JKS keystore uses a proprietary format. It is recommended to migrate to PKCS12 which is an industry standard format using "keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore.jks -deststoretype pkcs12".
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]# ls
LICENSE.txt  NOTICE.txt  README.asciidoc  bin  config  data  elastic-certificates.p12  elastic-stack-ca.p12  jdk  keystore.jks  lib  logs  modules  plugins
[root@r9us45kbhkhg7v58 elasticsearch-8.5.3]#
```


### 七、参考文档
[Elasticsearch Security Settings](https://www.elastic.co/guide/en/elasticsearch/reference/8.5/security-settings.html)
[elasticsearch8安装使用](https://www.jianshu.com/p/c6ad06b20a18)
[elasticsearch8集群安装部署使用](https://www.jianshu.com/p/7e4b419cdfd1)
[Elasticsearch 8.X 集群部署](http://www.dbaselife.com/project-16/doc-1534/)