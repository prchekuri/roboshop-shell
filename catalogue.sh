source common.sh
#log1=/tmp/catalogue.log

#echo -e "\e[35m Configuring NodeJS repos \e[0m"
print_head "Configuring NodeJS repos"
#set -e (to stop the script where it gets errors)
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "Install NodeJS"
yum install nodejs -y &>>${LOG}
status_check

print_head "Add Application User"
useradd roboshop &>>${LOG}
status_check
#status_check $log1

mkdir -p /app &>>${LOG}

print_head "Downloading App Content"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

print_head "Cleanup Old Content"
rm -rf /app/*  &>>${LOG}
status_check

print_head "Extracting App Content"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

print_head "Installing NodeJS Dependencies"
cd /app
npm install &>>${LOG}
status_check

print_head "Configuring Catalogue Service File"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

print_head "Reload SysyemD"
systemctl daemon-reload &>>${LOG}
status_check

print_head "Enable Catalogue Service"
systemctl enable catalogue &>>${LOG}
status_check

print_head "Start Catalogue Service"
systemctl start catalogue &>>${LOG}
status_check

print_head "Configuring Mongodb Repo"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

print_head "Install Mongodb Client"
yum install mongodb-org-shell -y &>>${LOG}
status_check

print_head "Load Schema"
mongo --host mongodb.roboshop.internal </app/schema/catalogue.js &>>${LOG}
status_check