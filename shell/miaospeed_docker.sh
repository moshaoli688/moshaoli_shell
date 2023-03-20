#!/bin/sh
command=${1}

Install(){
    docker run -d -p 5220:9966 -p 9966:9966 \
    -m 2g  --memory-swap -1 \
    --name=miaospeed --restart=always  \
    -e MIAOSPEED_MTLS=1  \
    -e MIAOSPEED_CONNTHREAD=16 \
    -e MIAOSPEED_WHITELIST=5451781317,5563434052,6198307617,5685382633,5713834539,6253253025,5335449558 \
    moshaoli688/miaospeed:latest
    docker run -d --name watchtower_miaospeed --restart always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --interval 3600 miaospeed
}
ReInstall(){
    docker stop miaospeed watchtower_miaospeed
    docker rm miaospeed watchtower_miaospeed
    docker pull moshaoli688/miaospeed:latest
    Install
}
Update(){
    docker stop miaospeed
    docker rm miaospeed
    docker pull moshaoli688/miaospeed:latest
    Install
}
Uninstall(){
    docker stop miaospeed watchtower_miaospeed
    docker rm miaospeed watchtower_miaospeed
}
echo "========================================================================================="
echo "本脚本依赖 docker compose扩展，若没有请使用 docker版脚本"
echo "本脚本支持自动升级。"
echo "Docker脚本：https://raw.githubusercontent.com/moshaoli688/moshaoli_shell/master/shell/miaospeed_docker.sh"
echo "Docker Compose脚本：https://raw.githubusercontent.com/moshaoli688/moshaoli_shell/master/shell/miaospeed_compose.sh"
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