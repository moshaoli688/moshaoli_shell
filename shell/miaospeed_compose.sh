#!/bin/sh
command=${1}

Install(){
    if [ -d "./miaospeed-ffq/" ]; then
     echo "已经安装拉。。升级请使用 update"
     exit 1
    fi
    echo "创建目录./miaospeed-ffq/"
    mkdir ./miaospeed-ffq/
    cd ./miaospeed-ffq/
    echo 下载docker compose文件
    wget http://valve.file.myan.cc/miaoko/docker-compose.yaml
    echo "正在部署 请稍后"
    docker compose up -d
    echo "部署完毕"
    echo "默认端口：9966"
}
ReInstall(){
    cd ./miaospeed-ffq/
    docker compose down
    cd ..
    rm -rf ./miaospeed-ffq/
    Install
}
Update(){
    cd ./miaospeed-ffq/
    docker compose down
    docker pull moshaoli688/miaospeed:latest
    docker compose up -d
    echo "升级完毕"
}
Uninstall(){
    cd ./miaospeed-ffq/
    docker compose down
    cd ..
    rm -rf ./miaospeed-ffq/
    echo "已删除"
}
echo "========================================================================================="
echo "本脚本依赖 docker compose扩展，若没有请使用 docker版脚本"
echo "本脚本支持自动升级。"
echo "Docker脚本：http://valve.file.myan.cc/miaoko/DockerMiaospeed/miaospeed_docker.sh"
echo "Docker Compose脚本：http://valve.file.myan.cc/miaoko/DockerMiaospeed/miaospeed_docker.sh"
echo "========================================================================================="
if [ -z "$command" ];then
    echo 安    装 ${0} install
    echo 重新安装 ${0} reinstall
    echo 更    新 ${0} update
elif [ $command = 'install' ];then
    Install
elif [ $command = 'update' ];then
    Update
elif [ $command = 'reinstall' ];then
    ReInstall
elif [ $command = 'uninstall' ];then
    Uninstall
else
    exit 1
fi