#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear


Setting_node_information(){
	clear;echo "设定服务端信息:"
	read -p "(1/3)前端地址:" Front_end_address
		if [[ ${Front_end_address} = '' ]];then
			Front_end_address=`curl -s "https://myip.ipip.net" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
			echo "emm,我们已将前端地址设置为:http://${Front_end_address}"
		fi
	read -p "(2/3)节点ID:" Node_ID
	read -p "(3/3)Mukey:" Mukey
	if [[ ${Mukey} = '' ]];then
		Mukey='mupass';echo "未设置该项,默认Mukey值为:mupass"
	fi
	echo;echo "Great！即将开始安装...";echo;sleep 2.5
}

install_node_for_debian(){
	apt-get -y update
	cd /root
	apt-get -y install build-essential wget python-dev libffi-dev openssl python-pip libssl-dev zip unzip git
        wget https://github.com/1989kxl/libsodium/releases/download/1.0.17/libsodium-1.0.17.tar.gz
        tar xf libsodium-1.0.17.tar.gz && cd libsodium-1.0.17
        ./configure && make -j2 && make install
        ldconfig
        cd .. && rm -f libsodium-1.0.17.tar.gz && rm -rf libsodium-1.0.17
	cd /root
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
}

Setting_node_information
install_node_for_debian



