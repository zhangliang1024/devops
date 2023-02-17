#!/bin/bash

function runapp(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element"/build.sh"
        if [ -f $dir_or_file ]
        then
            cd $1"/"$element
                if [ "$element" == "eureka" ] || [ "$element" == "zuul" ] || [ "$element" == "xxl-job" ] || [ "$element" == "web" ] || [ "$element" == "monitor" ]

                then
                    echo $dir_or_file  jump this
                else
                        rm -rf *.jar
                        echo $dir_or_file remove jar
                fi
        else
            echo $dir_or_file "无此文件"
        fi
    done
}
root_dir="/usr/local/project"
runapp $root_dir
