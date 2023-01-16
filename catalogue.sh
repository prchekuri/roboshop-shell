source common.sh
#log1=/tmp/catalogue.log

echo -e "\e[35m Configuring NodeJS repos\e[0m"
#set -e (to stop the script where it gets errors)
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

echo -e "\e[35m Install NodeJS\e[0m"
yum install nodejs -y &>>${LOG}
status_check

echo -e "\e[35m Add Application User\e[0m"
useradd roboshop &>>${LOG}
status_check
#status_check $log1

mkdir -p /app &>>${LOG}

echo -e "\e[35m Downloading App Content\e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

echo -e "\e[35m Cleanup Old Content\e[0m"
rm -rf /app/*  &>>${LOG}
status_check

echo -e "\e[35m Extracting App Content\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

echo -e "\e[35m Installing NodeJS Dependencies\e[0m"
cd /app
npm install &>>${LOG}
status_check

echo -e "\e[35m Configuring Catalogue Service File\e[0m"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

echo -e "\e[35m Reload SysyemD\e[0m"
systemctl daemon-reload &>>${LOG}
status_check

echo -e "\e[35m Enable Catalogue Service\e[0m"
systemctl enable catalogue &>>${LOG}
status_check

echo -e "\e[35m Start Catalogue Service\e[0m"
systemctl start catalogue &>>${LOG}
status_check

echo -e "\e[35m Configuring Mongodb Repo\e[0m"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

echo -e "\e[35m Install Mongodb Client\e[0m"
yum install mongodb-org-shell -y &>>${LOG}
status_check

echo -e "\e[35m Load Schema\e[0m"
mongo --host mongodb.roboshop.internal </app/schema/catalogue.js &>>${LOG}
status_check