#!/bin/bash
# tag::code[]
# 定义颜色

BLUE_COLOR="\033[36m"
RED_COLOR="\033[31m"
GREEN_COLOR="\033[32m"
VIOLET_COLOR="\033[35m"
YELLOW_COLOR="\033[33m"
RES="\033[0m"

# 软件所在 http 服务器。
BASE_URL=http://software.jcohy.com
# 脚本所在 http 服务器。
BASH_SHELL=http://software.jcohy.com/bash/deploy

# 软件下载目录
BASE_DIR=/opt/software
INSTALL_DIR=/usr/local

# 版本号
JDK_VERSION=11
TOMCAT_VERSION=7
MYSQL_VERSION=8
NACOS_VERSION=2.2.0
SEATA_VERSION=1.6.1
SENTINEL_VERSION=1.8.0

# 软件包名
JDK_PACKAGE=OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz
TOMCAT_PACKAGE=apache-tomcat-7.0.94.tar.gz
MYSQL_PACKAGE=mysql-8.0.19-1.el7.x86_64.rpm-bundle.tar
GCC_PACKAGE=gcc-8.3.0.build.tar.gz
NGINX_PACKAGE=nginx-1.6.2.build.tar.gz
NACOS_PACKAGE=nacos-server-2.2.0.tar.gz
SEATA_PACKAGE=seata-server-1.6.1.tar.gz
SENTINEL_PACKAGE=sentinel-dashboard-1.8.0.jar

#使用说明，用来提示输入参数
usage() {
	echo -e "${BLUE_COLOR}如果需要安装 jdk，请执行  source ./native.sh jdk${RES}"
	echo -e "${BLUE_COLOR}如果需要安装 tomcat，请执行  ./native.sh tomcat${RES}"
	echo -e "${BLUE_COLOR}如果需要安装 mysql，请执行  ./native.sh mysql${RES}"
	echo -e "${BLUE_COLOR}如果需要安装 nginx，请执行  ./native.sh nginx${RES}"
	echo -e "${BLUE_COLOR}如果需要安装 nacos，请执行  ./native.sh nacos${RES}"
	echo -e "${BLUE_COLOR}如果需要安装 seata，请执行  ./native.sh seata${RES}"
  echo -e "${BLUE_COLOR}如果需要安装 sentinel，请执行  ./native.sh sentinel${RES}"
	echo -e "${BLUE_COLOR}如果需要安装以上全部软件，请执行  ./native.sh all${RES}"
	exit 1
}


download(){
	wget -N $BASE_URL/$1/$2
}

jdk(){
	if [ -x "$(command -v java)" ];then
		echo "====================== JDK 已存在,JAVA_HOME='$JAVA_HOME' ======================"
	else
		echo "====================== 开始安装 JDK ======================"
		wget -N $BASE_URL/jdk/$JDK_VERSION/$JDK_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$JDK_PACKAGE -C ${INSTALL_DIR}
		cat >> /etc/profile << EOF
export JAVA_HOME=${INSTALL_DIR}/jdk-11.0.11+9
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
		echo "====================== JDK 已安装完成，JAVA_HOME='$JAVA_HOME' ======================"
	fi
}

nginx(){
	if [ -d "$BASE_DIR/nginx" ];then
		echo "====================== NGINX 已存在 ======================"
	else
		echo "====================== 开始安装 NGINX ======================"
		wget -N $BASE_URL/nginx/$NGINX_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$NGINX_PACKAGE -C ${INSTALL_DIR}
		${INSTALL_DIR}/nginx/sbin/nginx
		ps -ef|grep nginx | awk 'NR==1{ print $2 }'
		if [ $? -eq 0 ];then
		echo "====================== NGINX 已安装完成! ======================"
		else
		echo "====================== NGINX 安装失败!，请检查文件是否存在！ ======================"
		fi
		
	fi
}

installGCC(){
	if [ -x "$(command -v gcc)" ];then
		echo "GCC 已存在"
	else
		echo "====================== 安装 gcc ======================"
		wget -N $BASE_URL/gcc/$GCC_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$GCC_PACKAGE -C ${INSTALL_DIR}
		cd ${INSTALL_DIR}/gcc8.3.0build
		rm -rf /usr/bin/gcc
		rm -rf /usr/bin/g++
		ln -s ${INSTALL_DIR}/gcc8.3.0build/bin/gcc /usr/bin/gcc
		ln -s ${INSTALL_DIR}/gcc8.3.0build/bin/g++ /usr/bin/g++
		cp ${INSTALL_DIR}/gcc8.3.0build/lib64/libstdc++.so.6.0.25  /usr/lib64/libstdc++.so.6.0.25
		rm -f /usr/lib64/libstdc++.so.6
		ln /usr/lib64/libstdc++.so.6.0.25 /usr/lib64/libstdc++.so.6
		echo "====================== GCC 安装完成 ======================"
		echo "====================== GCC 版本 ======================"
		gcc -v
		strings /usr/lib64/libstdc++.so.6|grep GLIBC
	fi
}

mysql(){
	
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 sql.sh! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	test ! -e "./sql.sh" && wget -N http://software.jcohy.com/bash/deploy/sql.sh && chmod +x sql.sh
	test ! -x "./sql.sh" && chmod +x sql.sh
	echo -e "${YELLOW_COLOR}>>>>>>>>>>>>>>>>>>>>> 加载 sql.sh 成功! <<<<<<<<<<<<<<<<<<<<<<<${RES}"
	
	if [ -x "$(command -v mysql)" ];then
		echo "====================== mysql 已存在======================"
	else
		echo "======================安装 mysql ======================"
		wget -N $BASE_URL/mysql/$MYSQL_VERSION/$MYSQL_PACKAGE -P $BASE_DIR
		cd $BASE_DIR
		tar -xvf $BASE_DIR/$MYSQL_PACKAGE 
		echo "---------->>删除依赖"
		rpm -qa|grep mariadb-libs | xargs rpm -e  --nodeps
		#安装必要依赖
		echo "---------->>安装依赖项"
		yum install -y libaio net-tools perl numactl
		echo "---------->>安装Mysql"
		rpm -ivh mysql-community-common-8.0.19-1.el7.x86_64.rpm
		rpm -ivh mysql-community-libs-8.0.19-1.el7.x86_64.rpm
		rpm -ivh mysql-community-client-8.0.19-1.el7.x86_64.rpm
		rpm -ivh mysql-community-server-8.0.19-1.el7.x86_64.rpm
		echo '---------->>启动Mysql'
		systemctl enable mysqld
		systemctl start mysqld
		
		#pattern="^(?![A-Za-z0-9]+$)(?![a-z0-9\\W]+$)(?![A-Za-z\\W]+$)(?![A-Z0-9\\W]+$)[a-zA-Z0-9\\W]{8,}$"
		#while [[ "$newPassword" =~ $pattern ]]
		#do
		read -p '准备修改mysql密码，请输入新密码: 新密码必须包含大小写字母、数字和特殊符号，并且长度不能少于8位。' newPassword
		#done
		# grep 'temporary password' /var/log/mysqld.log | sed -r 's/.*localhost: (.*)/\1/g'
		cd ~
		password=`grep 'temporary password' /var/log/mysqld.log|tail -n 1| awk '{print $NF}'`
		echo "---------->>mysql 默认密码: "$password
		./sql.sh $password $newPassword
		echo "====================== 开启端口访问======================"
		#firewall-cmd --permanent --zone=public --add-port=3306/tcp
		#firewall-cmd --permanent --zone=public --add-port=3306/udp
		#firewall-cmd --reload
		#firewall-cmd --list-ports 
		echo "====================== mysql 安装完成 Mysql密码为'$newPassword'======================"
	fi
}

tomcat(){
	echo '====================== 安装 tomcat ======================'
	#pid=ps -ef | grep "tomcat" | grep -v grep | awk '{print $2}'
	filename=${TOMCAT_PACKAGE%.tar.gz}
	unzipUrl=${INSTALL_DIR}/$filename
	if [ ! -d "$unzipUrl" ];then
		wget -N $BASE_URL/tomcat/$TOMCAT_VERSION/$TOMCAT_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$TOMCAT_PACKAGE -C ${INSTALL_DIR}/
		${INSTALL_DIR}/apache-tomcat-7.0.94/bin/startup.sh
		echo "====================== tomcat安装完成 ======================"	
	else
		echo "====================== tomcat目录已存在 ======================"
		echo "====================== tomcat目录: ======================"$unzipUrl
	fi
}

nacos(){
	echo '====================== 安装 nacos ======================'
	#pid=ps -ef | grep "nacos" | grep -v grep | awk '{print $2}'
	filename=${NACOS_PACKAGE%.tar.gz}
	unzipUrl=${INSTALL_DIR}/$filename
	if [ ! -d "$unzipUrl" ];then
		wget -N $BASE_URL/nacos/$NACOS_VERSION/$NACOS_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$NACOS_PACKAGE -C ${INSTALL_DIR}/
		${INSTALL_DIR}/nacos/bin/startup.sh -m standalone
		echo "====================== nacos 安装完成 ======================"
	else
		echo "====================== nacos 目录已存在 ======================"
		echo "====================== nacos 目录: ======================"$unzipUrl
	fi
}

seata(){
	echo '====================== 安装 seata ======================'
	#pid=ps -ef | grep "seata" | grep -v grep | awk '{print $2}'
	filename=${SEATA_PACKAGE%.tar.gz}
	unzipUrl=${INSTALL_DIR}/$filename
	if [ ! -d "$unzipUrl" ];then
		wget -N $BASE_URL/seata/$SEATA_VERSION/$SEATA_PACKAGE -P $BASE_DIR
		tar -zxvf $BASE_DIR/$SEATA_PACKAGE -C ${INSTALL_DIR}/
		${INSTALL_DIR}/seata/bin/seata-server.sh -p 8091 -m file
		echo "====================== seata 安装完成 ======================"
		echo -e "${BLUE_COLOR} 注意，您需要根据自己的配置去修改 file.conf 和 registry.conf 文件！！！${RES}"
	else
		echo "====================== seata 目录已存在 ======================"
		echo "====================== seata 目录: ======================"$unzipUrl
	fi
}

sentinel(){
	echo '====================== 启动 sentinel 控制台======================'
	#pid=ps -ef | grep "sentinel" | grep -v grep | awk '{print $2}'
	if [ ! -d "$INSTALL_DIR/sentinel" ]; then
	    mkdir "$INSTALL_DIR/sentinel"
	    wget -N $BASE_URL/sentinel/$SENTINEL_VERSION/$SENTINEL_PACKAGE -P $INSTALL_DIR/sentinel
	    cd $INSTALL_DIR/sentinel
	    nohup java -jar $SENTINEL_PACKAGE > sentinel.log 2>&1 &
	    echo $! > ./run.pid
	    echo '====================== 启动 sentinel 控制台 成功======================'
	fi
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"jdk")
	jdk
;;
"tomcat")
	tomcat
;;
"mysql")
	mysql
;;
"gcc8")
	installGCC
;;
"nginx")
	nginx
;;
"nacos")
	nacos
;;
"seata")
	seata
;;
"sentinel")
	sentinel
;;
"all")
	jdk
	tomcat
	nginx
	mysql
;;
*)
	usage
;;
esac
# end::code[]