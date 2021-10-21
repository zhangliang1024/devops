
### Broker配置说明
```bash
#集群名字
brokerClusterName = DefaultCluster
#broker名字，不同的配置文件填写的不一样 
brokerName = broker-a
#0 表示 Master，>0 表示 Slave
brokerId = 0
#
brokerIp=127.0.0.1
#nameServer地址，分号分割
namesrvAddr=127.0.0.1:9876

#ASYNC_MASTER 异步复制Master, SYNC_MASTER 同步双写Master
brokerRole = ASYNC_MASTER
#ASYNC_FLUSH 异步刷盘, SYNC_FLUSH 同步刷盘
flushDiskType = ASYNC_FLUSH

#默认创建的队列数TOPIC
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外监听端口
listenPort=10911
#回查事务消息
checkTransactionMessageEnable=false
#发消息线程池数量
sendMessageTreadPoolNums=128
#拉消息线程池数量
pullMessageTreadPoolNums=128

#commitlog目录所在的分区使用比例大于该值，则触发过期文件删除，默认75
diskMaxUsedSpaceRatio=80
#存储路径
storePathRootDir=/data/rocketmq/store
#commitLog 存储路径
storePathCommitLog=/data/rocketmq/store/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/data/rocketmq/store/consumequeue
#消息索引存储路径
storePathIndex=/data/rocketmq/store/index
#checkpoint 文件存储路径
storeCheckpoint=/data/rocketmq/store/checkpoint
#abort 文件存储路径
abortFile=/data/rocketmq/store/abort
#限制的消息大小
maxMessageSize=65536
#一次刷盘至少需要脏页的数量，针对Commitlog文件，默认4
flushCommitLogLeastPages=4
#一次刷盘至少需要脏页的数量，针对Consume文件，默认2
flushConsumeQueueLeastPages=2
#Commitlog两次刷盘的最大间隔，如果超过该间隔，将fushCommitLogLeastPages要求直接执行刷盘操作，默认10000
flushCommitLogThoroughInterval=10000
#Consume两次刷盘的最大间隔，如果超过该间隔，将忽略，默认60000
flushConsumeQueueThoroughInterval=60000

#删除文件时间点，默认凌晨 4点
deleteWhen = 04
#文件保留时间，默认 48 小时 
fileReservedTime = 48
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#销毁MappedFile被拒绝的最大存活时间，默认120s
destroyMapedFileIntervalForcibly=120000
#重试删除文件间隔，配合destorymapedfileintervalforcibly，默认120s
redeleteHangedFileInterval=120000
```