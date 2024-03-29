#!/bin/bash
# tag::code[]
# 定义颜色

BLUE_COLOR="\033[36m"
RED_COLOR="\033[31m"
GREEN_COLOR="\033[32m"
VIOLET_COLOR="\033[35m"
YELLOW_COLOR="\033[33m"
RES="\033[0m"

# 脚本所在 http 服务器。
BASH_CONFIG=http://software.jcohy.com/bash

usage() {
	echo -e "${BLUE_COLOR}docker 方式安装，请执行 ./deploy.sh docker${RES}"
	echo -e "${BLUE_COLOR}native 方式安装，请执行 ./deploy.sh native${RES}"
	echo -e "${BLUE_COLOR}native 方式卸载，请执行 ./deploy.sh unnative${RES}"
	echo -e "${BLUE_COLOR}docker 方式卸载，请执行 ./deploy.sh undocker${RES}"
	echo -e "${BLUE_COLOR}开启端口，请执行  ./deploy.sh port${RES}"
	exit 1
}


port(){
	#nginx
	firewall-cmd --add-port=80/tcp --permanent
	firewall-cmd --add-port=443/tcp --permanent
	firewall-cmd --add-port=8000/tcp --permanent	
	#mysql
	firewall-cmd --add-port=3306/tcp --permanent
	
	#redis
	firewall-cmd --add-port=6379/tcp --permanent

	#tomcat
	firewall-cmd --add-port=8080/tcp --permanent
	
	#nacos
	firewall-cmd --add-port=8848/tcp --permanent
	
	#sentinel
	firewall-cmd --add-port=8858/tcp --permanent
	
	#minio
	firewall-cmd --add-port=9001/tcp --permanent
	
	#elk
	firewall-cmd --add-port=5601/tcp --permanent
	firewall-cmd --add-port=9100/tcp --permanent
	firewall-cmd --add-port=5044/tcp --permanent
	firewall-cmd --add-port=9000/tcp --permanent
	
	#grafana
	firewall-cmd --add-port=3000/tcp --permanent
	
	#zipkin
	firewall-cmd --add-port=9411/tcp --permanent
	
	#redis
	firewall-cmd --add-port=5672/tcp --permanent
	firewall-cmd --add-port=15672/tcp --permanent
	service firewalld restart
	firewall-cmd --list-ports
}

download(){
	wget -N $BASH_CONFIG/deploy/$1
}


echo -e "${VIOLET_COLOR}########################################################################${RES}"
echo -e "${VIOLET_COLOR}#                           Deploy Script                              #${RES}"
echo -e "${VIOLET_COLOR}########################################################################${RES}"

cd ~

echo -e "${RED_COLOR}>>>>>>>>>>>>>>>>>>>>>>>> Start Install Dependency <<<<<<<<<<<<<<<<<<<<<<${RES}"
if  [ -x "$(command -v expect)" ];then
    echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> expect      already install! <<<<<<<<<<<<<<<<<<<<<${RES}"
else
    echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>> expect is not install,start install expect! <<<<<<<<<<<<<${RES}"
    #安装expect
    yum install -y expect
fi

if [ -x "$(command -v wget)" ];then
    echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> wget        already install! <<<<<<<<<<<<<<<<<<<<<${RES}"
else
    echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>> wget is not install,start install expect!       <<<<<<<<<<<${RES}"
    #安装wget
    yum install -y wget 
fi

echo -e "${RED_COLOR}>>>>>>>>>>>>>>>>>>>>>>>> End Install Dependency <<<<<<<<<<<<<<<<<<<<<<<<${RES}"


#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"native")
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 native.sh! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	test ! -e "./native.sh" && download native.sh && chmod +x native.sh
	test ! -x "./native.sh" && chmod +x native.sh
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 native.sh 成功! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 开始执行 native.sh... <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	exec ./native.sh $2
;;
"docker")
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 docker.sh! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	test ! -e "./docker.sh" && download docker.sh && chmod +x docker.sh
	test ! -x "./docker.sh" && chmod +x docker.sh
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 docker.sh 成功! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 开始执行 docker.sh... <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	exec ./docker.sh $2
;;
"unnative")
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 unnative.sh! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	test ! -e "./unnative.sh" && download unnative.sh && chmod +x unnative.sh
	test ! -x "./unnative.sh" && chmod +x unnative.sh
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 unnative.sh 成功! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 开始执行 unnative.sh... <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	exec ./unnative.sh $2
;;
"undocker")
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 undocker.sh! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	test ! -e "./undocker.sh" && download undocker.sh && chmod +x undocker.sh
	test ! -x "./undocker.sh" && chmod +x undocker.sh
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 undocker.sh 成功! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 开始执行 undocker.sh... <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	exec ./undocker.sh $2
;;
"port")
	port
;;
*)
	usage
;;
esac
# end::code[]