#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
echo
echo "#############################################################"
echo "# 一键对接SSR后端modwebapi版本，支持Debian8+/Ubuntu16+      #"
echo "# Author: Chikage <csp85123@gmail.com>                      #"
echo "# Blog: www.94ish.me                                        #"
echo "#############################################################"
echo
read -p "请输入此节点在面板中的ID号: " nodeid
read -p "请输入完整面板域名/ip地址（例如https://www.94ish.me）: " host
read -p "请输入modwebapi验证密钥: " pass
read -p "请输入测速时间间隔（默认6）：" speedtest
if [ -z "${speedtest}" ];then  
    speedtest=6 
fi
echo "开始部署"
sleep 2s
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cd /root
apt-get update
apt-get -y install build-essential wget python-dev libffi-dev openssl python-pip libssl-dev zip unzip git
wget https://github.com/1989kxl/libsodium/releases/download/1.0.17/libsodium-1.0.17.tar.gz
tar xf libsodium-1.0.17.tar.gz && cd libsodium-1.0.17
./configure && make -j2 && make install
ldconfig
cd .. && rm -f libsodium-1.0.17.tar.gz && rm -rf libsodium-1.0.17
git clone -b manyuser https://github.com/1989kxl/shadowsocks.git
cd shadowsocks
pip install --upgrade setuptools
pip install -r requirements.txt
cp apiconfig.py userapiconfig.py
cp config.json user-config.json
chmod +x *.sh
	
	sed -i "17c WEBAPI_URL = \'${Front_end_address}\'" /root/shadowsocks/userapiconfig.py
	sed -i "2c NODE_ID = ${Node_ID}" /root/shadowsocks/userapiconfig.py
	sed -i "18c WEBAPI_TOKEN = \'${Mukey}\'" /root/shadowsocks/userapiconfig.py




