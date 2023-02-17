#!/bin/bash
case "$1" in
    -h|--help|?)
    echo "Usage: 1st arg: docker version name, 2st arg: env name"
    echo "1st arg e.g. : uat/test/1.0.0/latest"
    echo "2st arg e.g. : uat/test/dev/smoketest"
    exit 0
;;
esac

VERSION=$1
ENV=$2
if [ -n "$1" ] ;then
    echo "第一个参数为docker镜像版本，当前值是：$1"
else
    echo "请输入一个docker镜像版本参数，例如: sh start_all.sh uat uat"
    exit 1;
fi

if [ -n "$2" ] ;then
    echo -e "第二个参数为环境变量，当前值是：$2 \n"
else
    echo "请输入二个环境变量参数，例如: sh start_all.sh uat uat"
    exit 1;
fi


function runapp(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element"/deploy.sh"
        if [ -f $dir_or_file ]
        then
            cd $1"/"$element
                echo -e "=====================执行目录:$1"/"$element======================="
                if [ "$element" == "eureka" ] || [ "$element" == "zuul" ] || [ "$element" == "xxl-job" ] || [ "$element" == "monitor" ] || [ "$element" == "zipkin" ] || [ "$element" == "web" ]
                then
                        #sh deploy.sh latest $ENV
                        #echo $dir_or_file sh deploy.sh latest $ENV
                        echo -e $dir_or_file  jump this "\n"
                else
                        sh deploy.sh $VERSION $ENV
                        echo -e "执行命令:" $1"/"$element sh deploy.sh $VERSION $ENV "\n"
                fi
        else
            echo -e $dir_or_file "无此文件\n"
        fi
    done
}
root_dir="/usr/local/project"
runapp $root_dir