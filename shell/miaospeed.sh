#!/bin/sh
MiaoSpeedVer=$(curl -s https://api.github.com/repos/moshaoli688/miaospeed/releases/latest | grep tag_name | cut -f4 -d "\"" | sed 's/v//g')
MIAOSPEED_TEMP="/opt"
GithubMirrorURL="https://github.com"
MIAOSPEED_HOME="/usr/miaospeed"
command=${1}
[ -d "$MIAOSPEED_HOME" ] || mkdir -p "$MIAOSPEED_HOME" && mkdir -p "$MIAOSPEED_HOME/bin"
if [ -e $MIAOSPEED_HOME/bin/miaospeed ]; then
    MiaoSpeedLocalVer=$($MIAOSPEED_HOME/bin/miaospeed -version | grep -oP '^\d+\.\d+\.\d+')
else
    MiaoSpeedLocalVer="未安装"
fi
CheckSystem() {
    SUFX=""
    case $(arch) in
    i386) SUFX="32" ;;
    i686) SUFX="32" ;;
    x86_64) SUFX="64" ;;
    arm) SUFX="arm32-v5" ;;
    armv6) SUFX="arm32-v6" ;;
    armv6l) SUFX="arm32-v6" ;;
    armv7) SUFX="arm32-v7a" ;;
    armv7l) SUFX="arm32-v7a" ;;
    aarch64) SUFX="arm64-v8a" ;;
    esac
    SUFXMIAOSPEED=""
    case "$SUFX" in
    32) SUFXMIAOSPEED="386" ;;
    64) SUFXMIAOSPEED="amd64" ;;
    arm32-v5) SUFXMIAOSPEED="" ;;
    arm32-v6) SUFXMIAOSPEED="" ;;
    arm32-v7a) SUFXMIAOSPEED="" ;;
    arm64-v8a) SUFXMIAOSPEED="arm64" ;;
    esac

    if [ ! "$MiaoSpeedVer" ]; then
        echo 'ERROR:The version number was not obtained'
        exit
    fi
    if [ ! $SUFXMIAOSPEED ]; then
        echo 'ERROR:This version is not supported'
        exit
    fi
    Menu
}
Menu() {
    #clear
    echo "============================================================"
    echo "          MiaoSpeed For Linux ($SUFXMIAOSPEED)一键管理脚本"
    echo ""
    echo "               1.注册服务  2.启动服务"
    echo ""
    echo "               3.停止服务  4.重启服务"
    echo ""
    echo "               5.更新服务  6.更新MMDB"
    echo ""
    echo "               7.卸载服务  0.退出"
    echo ""
    echo "             MiaoSpeed Local Ver:$MiaoSpeedLocalVer"
    echo ""
    echo "             MiaoSpeed Github Ver:$MiaoSpeedVer"
    echo ""
    if [ "$MiaoSpeedLocalVer" != "$MiaoSpeedVer" ]; then
        echo "         MiaoSpeed有更新,可选择更新服务自动更新"
    fi
    echo "============================================================"
    read -p "请输入选择项目的序号: " ID
    case $ID in
    "1") CheckServer ;;
    "2") StartService ;;
    "3") StopService ;;
    "4") RestartService ;;
    "5") UpdateService ;;
    "6") UpdateMMDB ;;
    "7") UninstallService ;;
    "0") Exit ;;
    *) Menu ;;
    esac
}

CheckServer() {
    clear
    echo CheckServer
    if [ -e /usr/lib/systemd/system/miaospeed.service ]; then
        read -p "服务已存在按任意键返回"
        Menu
    else
        InstallService
    fi
}
InstallService() {
    clear
    echo 开始安装服务,请稍后
    DownloadMiaoSpeed
    DownloadMMDB
    cat >/usr/lib/systemd/system/miaospeed.service <<EOF
[Unit]
Description=MiaoSpeed Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
WorkingDirectory=$MIAOSPEED_HOME
ExecStart=$MIAOSPEED_HOME/bin/miaospeed.meta server -bind 0.0.0.0:19966  -mtls -whitelist 5685382633,5713834539,5335449558,5563434052,5451781317,6253253025,6198307617 -connthread 16 -mmdb GeoLite2-ASN.mmdb,GeoLite2-City.mmdb
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl start miaospeed
    systemctl enable miaospeed
    MiaoSpeedLocalVer=$($MIAOSPEED_HOME/bin/miaospeed -version | grep -oP '^\d+\.\d+\.\d+')

    echo ""
    echo -e "    已部署完毕,"
    echo ""
    echo -e "    服务状态：$(systemctl is-active miaospeed.service)"
    echo ""
    echo -e "    请保证该机器稳定在线."
    echo ""
    echo -e "    请不定期执行脚本进行更新,"
    echo ""
    echo -e "    并更新MMDB GeoIP数据库."
    echo ""
    echo -e "    请勿在本机使用代理软件或软路由连接,"
    echo ""
    echo -e "    请勿私自卸载,请勿泄露服务端配置信息,"
    echo ""
    echo -e "    如发现不在线或者泄露服务器信息,将取消授权,永久拉黑."
    echo ""
    echo -e "    如有报错请截图发送至:https://t.me/msl_la_bot"
    echo ""
    read -p "按任意键返回"
    Menu
}
StartService() {
    clear
    echo StartService
    systemctl start miaospeed
    read -p "服务已启动"
    Menu
}
StopService() {
    clear
    echo StopService
    systemctl stop miaospeed
    read -p "服务已停止"
    Menu
}
RestartService() {
    clear
    echo RestartService
    systemctl restart miaospeed
    read -p "服务已重启"
    Menu
}
UpdateService() {
    clear
    echo 正在检查更新
    if [ "$MiaoSpeedLocalVer" != "$MiaoSpeedVer" ]; then
        clear
        echo 有更新,正在更新服务
        systemctl stop miaospeed
        rm $MIAOSPEED_HOME/bin/miaospeed*
        DownloadMiaoSpeed
        systemctl start miaospeed
        read -p "服务更新完毕"
        Menu
    fi
    read -p "无更新,按任意键返回"
    Menu
}
UpdateMMDB() {
    clear
    echo 正在更新MMDB
    systemctl stop miaospeed
    rm $MIAOSPEED_TEMP/*.mmdb
    DownloadMMDB
    systemctl start miaospeed
    read -p "MMDB更新完毕"
    Menu
}
UninstallService() {
    clear
    systemctl stop miaospeed
    systemctl disable miaospeed
    rm /usr/lib/systemd/system/miaospeed.service
    systemctl daemon-reload
    rm -rf $MIAOSPEED_HOME
    read -p "服务已卸载,按任意键返回"
    Menu
}
AutoUpdate() {
    MiaoSpeedVer=$(curl -s https://api.github.com/repos/moshaoli688/miaospeed/releases/latest | grep tag_name | cut -f4 -d "\"" | sed 's/v//g')
    MiaoSpeedLocalVer=$($MIAOSPEED_HOME/bin/miaospeed -version | grep -oP '^\d+\.\d+\.\d+')
    if [ "$MiaoSpeedLocalVer" != "$MiaoSpeedVer" ]; then
        clear
        echo 有更新,正在更新服务
        systemctl stop miaospeed
        rm $MIAOSPEED_HOME/bin/miaospeed*
        DownloadMiaoSpeed
        systemctl start miaospeed
        Menu
    fi
    echo 无更新
}
DownloadMiaoSpeed() {
    echo "正在下载MiaoSpeed,请稍后"
    url="$GithubMirrorURL/moshaoli688/miaospeed/releases/download/v$MiaoSpeedVer/miaospeed_"$MiaoSpeedVer"_linux_$SUFXMIAOSPEED.tar.gz"
    echo $url
    output="$MIAOSPEED_TEMP/miaospeed.tar.gz"
    wget -q --show-progress -O "$output" "$url"
    tar -zxvf $output -C $MIAOSPEED_HOME/bin/
    rm $MIAOSPEED_HOME/bin/*.md
    rm $output
}
DownloadMMDB() {
    echo "正在下载GeoLite2-ASN.mmdb,请稍后"
    url="$GithubMirrorURL/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb"
    output="$MIAOSPEED_TEMP/GeoLite2-ASN.mmdb"
    wget -q --show-progress -O "$output" "$url"
    cp $output $MIAOSPEED_HOME
    rm $output
    echo "正在下载GeoLite2-City.mmdb,请稍后"
    url="$GithubMirrorURL/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb"
    output="$MIAOSPEED_TEMP/GeoLite2-City.mmdb"
    wget -q --show-progress -O "$output" "$url"
    cp $output $MIAOSPEED_HOME
    rm $output
}

Exit() {
    exit 1
}
if [ -z "$command" ]; then
    CheckSystem
elif [ $command = 'check' ]; then
    AutoUpdate
else
    exit 1
fi
