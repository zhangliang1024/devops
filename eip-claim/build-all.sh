#!/bin/bash
case "$1" in
    -h|--help|?)
    echo "Usage: 1st arg: docker version name"
    echo "1st arg e.g. : uat/test/1.0.0/latest"
    exit 0
;;
esac

VERSION=$1
if [ -n "$1" ] ;then
    echo -e "第一个参数为docker镜像版本，当前值是：$1 \n"
else
    echo "请输入一个docker镜像版本参数，例如: sh start_all.sh uat uat"
    exit 1;
fi


function runapp(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element"/build.sh"
        if [ -f $dir_or_file ]
        then
            cd $1"/"$element
                echo -e "=====================执行目录:$1"/"$element======================="
                if [ "$element" == "eureka" ] || [ "$element" == "zuul" ] || [ "$element" == "xxl-job" ] || [ "$element" == "monitor" ] || [ "$element" == "zipkin" ] || [ "$element" == "web" ]
                then
                    echo -e $dir_or_file  jump this "\n"
                else
                        sh build.sh $VERSION
                        echo -e "执行命令:" $1"/"$element sh build.sh $VERSION "\n"
                fi
        else
            echo -e $dir_or_file "无此文件\n"
        fi
    done
}
root_dir="/usr/local/project"
runapp $root_dir