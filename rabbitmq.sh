source common.sh

if [ -z "${roboshop_rabbitmq_password}" ]
  then
    echo "Variable roboshop_rabbitmq_password is missing"
    exit
fi

print_head "Configuring Erlang YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "Configuring Rabbitmq YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "Install Erlang and Rabbitmq Server"
yum install erlang rabbitmq-server -y &>>${LOG}
status_check

print_head "Enable Rabbitmq Server"
systemctl enable rabbitmq-server &>>${LOG}
status_check

print_head "Start Rabbitmq Server"
systemctl start rabbitmq-server &>>${LOG}
status_check

print_head "Add Application User"
rabbitmqctl add_user roboshop ${roboshop_rabbitmq_password} &>>${LOG}
status_check

print_head "Add tags to Application User"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG}
status_check

print_head "Add permission to Application User"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
status_check