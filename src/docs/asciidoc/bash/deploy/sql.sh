#!/usr/bin/expect

#echo 'hello'
set password [lindex $argv 0] 
set newpassword [lindex $argv 1] 
spawn mysql -u root -p
expect "Enter password: "
send "$password\r\n"
expect "mysql> "
send "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Jcohy@1203';\r\n"
expect "mysql> "
send "set global validate_password.policy=0;\r\n"
expect "mysql> "
send "flush privileges;\r\n"
expect "mysql> "
send "CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$newpassword';\r\n"
expect "mysql> "
send "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$newpassword';\r\n"
expect "mysql> "
send "flush privileges;\r\n"
expect "mysql> "
send "use mysql\r\n"
expect "mysql> "
send "select host,user,plugin  from mysql.user;\r\n"
expect "mysql> "
send "exit;\r\n"
