#!/bin/bash

if [ -f $JAR_FILE_NAME ];then
  echo -e "\033[32m jar JAR_FILE_NAME $JAR_FILE_NAME 存在 \033[0m"
else
  echo -e "\033[31m jar 文件不存在 $JAR_FILE_NAME , 请定义环境变量 JAR_FILE_NAME \033[0m"
  exit -1
fi

if [ -n "$JAR_FILE_RENAME" ]; then
  echo "JAR_FILE_RENAME=$JAR_FILE_RENAME rename $JAR_FILE_NAME to $JAR_FILE_RENAME"
  mv $JAR_FILE_NAME $JAR_FILE_RENAME
else
  JAR_FILE_RENAME=$JAR_FILE_NAME
fi

config-pinpoint-agent.sh.bak

JAVA_OPTS=""

echo "test pinpoint collector status: $PINPOINT_COLLECTOR_IP"
PING_COLLECTOR_RESULT=`ping -w 1 $PINPOINT_COLLECTOR_IP`

if [ "${PING_COLLECTOR_RESULT:0:4}" = "PING" ]; then
	echo -e "ping $PINPOINT_COLLECTOR_IP \033[32m SUCCESS \033[0m"
	echo -e "\033[32m 启用 pinpoint agent \033[0m"

  HOST_NAME=`hostname`
  HOST_NAME_LENGTH=${#HOST_NAME}
  echo "$HOST_NAME length is $HOST_NAME_LENGTH"
  HOST_NAME_SHORT=$HOST_NAME
  if [ ${HOST_NAME_LENGTH} -gt 24 ]; then
          echo "hostname is longer than 24"
          HOST_NAME_SHORT=${HOST_NAME:0-24}
          echo $HOST_NAME_SHORT
  fi
  echo -e "使用 \033[32m $HOST_NAME_SHORT \033[0m 作为 pinpoint agentId"
	JAVA_OPTS="$JAVA_OPTS -javaagent:/pinpoint-agent/pinpoint-bootstrap-${PINPOINT_VERSION}.jar -Dpinpoint.agentId=${HOST_NAME_SHORT} -Dpinpoint.applicationName=${PINPOINT_APP_NAME}"
else
  echo -e "ping $PINPOINT_COLLECTOR_IP \033[31m FAILED \033[0m"
  echo -e "\033[31m 禁用 pinpoint agent \033[0m"
fi

echo "test sentinel status: $SENTINEL_IP"
PING_SENTINEL_RESULT=`ping -w 1 $SENTINEL_IP`

if [ "${PING_SENTINEL_RESULT:0:4}" = "PING" ]; then
	echo -e "ping $SENTINEL_IP \033[32m SUCCESS \033[0m"
	echo -e "\033[32m 启用 sentinel \033[0m"
	JAVA_OPTS="$JAVA_OPTS -Dcsp.sentinel.dashboard.server=$SENTINEL_IP:$SENTINEL_PORT"
else
	echo -e "ping $SENTINEL_IP \033[31m FAILED \033[0m"
  echo -e "\033[31m 禁用 sentinel \033[0m"
fi

echo "command line:"
echo "java $JAVA_OPTS -jar $JAR_FILE_RENAME"
java $JAVA_OPTS -jar $JAR_FILE_RENAME