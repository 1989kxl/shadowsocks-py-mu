#!/bin/bash

Shut_down_iptables(){
	yum -y install iptables iptables-services
	iptables -F;iptables -X
	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
	iptables -I FORWARD -p tcp --dport 25 -j DROP
        iptables -I INPUT -p tcp --dport 25 -j DROP
        iptables -I OUTPUT -p tcp --dport 25 -j DROP
	iptables-save > /etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
}

Shut_down_firewall(){
	yum -y install firewalld
	systemctl stop firewalld.service
	systemctl disable firewalld.service
}

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

install_node_for_centos(){
	#yum -y update
	yum -y groupinstall "Development Tools"
	yum -y install git gcc wget curl python-setuptools
	wget "https://github.com/1989kxl/shadowsocks-py-mu/releases/download/%E5%BA%93%E6%96%87%E4%BB%B6/get-pip.py"
	python get-pip.py;rm -rf python get-pip.py;mkdir python;cd python
	wget "https://github.com/1989kxl/shadowsocks-py-mu/releases/download/%E5%BA%93%E6%96%87%E4%BB%B6/python.zip";unzip python.zip
	pip install *.whl;pip install *.tar.gz;cd /root;rm -rf python
	pip install cymysql requests -i https://pypi.org/simple/
	
	cd /root;wget "https://github.com/1989kxl/libsodium/releases/download/1.0.18/libsodium-1.0.18.tar.gz"
	tar xf /root/libsodium-1.0.18.tar.gz;cd /root/libsodium-1.0.18;./configure;make -j2;make install;cd /root
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf;ldconfig
	
	wget -O /usr/bin/shadowsocks "https://raw.githubusercontent.com/1989kxl/shadowsocks-py-mu/master/node/ss";chmod 777 /usr/bin/shadowsocks
	yum -y install lsof lrzsz python-devel libffi-devel openssl-devel
	git clone -b manyuser https://github.com/1989kxl/shadowsocks.git "/root/shadowsocks"
	cd /root/shadowsocks;cp apiconfig.py userapiconfig.py;cp config.json user-config.json
	
	sed -i "17c WEBAPI_URL = \'${Front_end_address}\'" /root/shadowsocks/userapiconfig.py
	sed -i "2c NODE_ID = ${Node_ID}" /root/shadowsocks/userapiconfig.py
	sed -i "18c WEBAPI_TOKEN = \'${Mukey}\'" /root/shadowsocks/userapiconfig.py
}

Setting_node_information
install_node_for_centos
Shut_down_iptables
Shut_down_firewall
