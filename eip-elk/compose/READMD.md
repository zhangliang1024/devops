# ELK 日志收集


### 一、启动
```bash
docker-compose up -d
```

### 二、修改目录权限
> `${PWD}/elasticsearch`无访问权限会导致启动失败

```bash
chmod 777 ${PWD}/elasticsearch
```

### 三、在`logstash`中安装`json_lines`插件
```bash
# 进入logstash容器
docker-exec -it logstash /bin/bash

# 安装插件
cd /bin/
logstash-plugin install logstash-codec-json_lines

# 重启容器
docker restart logstash
```

情绪
聊天的本质是：情绪的分享与交换


男神指南针

聊天的本质：是情绪上的互动，感情上的升温，讯息上的交换。而聊天这个行为，只是通过一个介质来传播这些东西。

所以你和姑娘聊天的本质和重点，是让她了解你是谁，是个什么有样的人。你们之间适合什么样的关系，适合做朋友还是恋人？
在闲聊的过程中去展示自己，在试探她对你是否有好感的过程中，拉升你们之间的关系。

有时候聊天的本质更像是一场交易，因为在聊天的过程中，是在逐渐掀开自己的底牌。

保持陌生的绅士才有的姿态，我对你有友好是因为我的素养，并等于无条件的忍让和取悦对方。


每一次和异性聊天都有背后的意义
往近了说：为了调动对方的情绪，往远了说：为之后的约会做铺垫
与异性的聊天过程，满足这两点才称得上有效的沟通

“共情能力” 是男人和女人沟通的桥梁。
共情能力：能设身处地体验他人处境，从而达到感受和理解他人情感 的能力
一个人的共情能力，往往可以体现他的情商。

分析，字面背后的意思-影藏信息
1.对方在说这句话时的情绪
2.这句话背后的潜台词
3.对方期望得到的回应

聊天万能公式：理解情绪 + 回应情绪 + 调动情绪






