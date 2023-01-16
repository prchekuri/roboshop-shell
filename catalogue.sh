script_location=$(pwd)
LOG=/tmp/catalogue.log

echo -e "\e[35m Configuring NodeJS repos\e[0m"
#set -e (to stop the script where it gets errors)
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Install NodeJS\e[0m"
yum install nodejs -y &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Add Application User\e[0m"
useradd roboshop &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    echo "Refer log file for more information, Log - ${LOG} "
    exit
fi

mkdir -p /app &>>${LOG}

echo -e "\e[35m Downloading App Content\e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Cleanup Old Content\e[0m"
rm -rf /app/*  &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Extracting App Content\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Installing NodeJS Dependencies\e[0m"
cd /app
npm install &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Configuring Catalogue Service File\e[0m"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Reload SysyemD\e[0m"
systemctl daemon-reload &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Enable Catalogue Service\e[0m"
systemctl enable catalogue &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Start Catalogue Service\e[0m"
systemctl start catalogue &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Configuring Mongodb Repo\e[0m"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Install Mongodb Client\e[0m"
yum install mongodb-org-shell -y &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi

echo -e "\e[35m Load Schema\e[0m"
mongo --host mongodb.roboshop.internal </app/schema/catalogue.js &>>${LOG}
if [ $? -eq 0 ]
  then
    echo SUCCESS
  else
    echo FAILURE
    exit
fi