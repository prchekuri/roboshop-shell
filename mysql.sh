source common.sh

if [ -z "${root_mysql_password}" ]
  then
    echo "Variable root_mysql_password is missing"
    exit
fi

print_head "Disable MySQL default module"
dnf module disable mysql -y  &>>${LOG}
status_check

print_head "Copy MySQL Repo file"
cp ${script_location}/files/mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}
status_check

print_head "Install MySQL Server"
yum install mysql-community-server -y &>>${LOG}
status_check

print_head "Enable MySQL Database"
systemctl enable mysqld &>>${LOG}
status_check

print_head "Start MySQL DB"
systemctl restart mysqld &>>${LOG}
status_check

print_head "Reset MySQL DB default Password"
mysql_secure_installation --set-root-pass ${root_mysql_password} &>>${LOG}
status_check