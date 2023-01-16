script_location=$(pwd)
LOG=/tmp/roboshop.log
echo "log from catalogue - " ${log1}
echo "component is " ${component}
status_check(){
  if [ $? -eq 0 ]
    then
      echo -e "\e[1;32m SUCCESS\e[0m"
    else
      echo -e "\e[1;31m FAILURE\e[0m"
      echo "Refer log file for more information, Log - ${LOG}"
#     echo "log from catalogue - $1"
      exit
  fi
}

print_head(){
  echo -e "\e[1m $1 \e[0m"
}

NODEJS(){
  print_head "Configuring NodeJS repos"
  #set -e (to stop the script where it gets errors)
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  status_check

  print_head "Install NodeJS"
  yum install nodejs -y &>>${LOG}
  status_check

  print_head "Add Application User"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]
  then
    useradd roboshop &>>${LOG}
  fi
  status_check
  #status_check $log1

  mkdir -p /app &>>${LOG}

  print_head "Downloading App Content"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
  status_check

  print_head "Cleanup Old Content"
  rm -rf /app/*  &>>${LOG}
  status_check

  print_head "Extracting App Content"
  cd /app
  unzip /tmp/${component}.zip &>>${LOG}
  status_check

  print_head "Installing NodeJS Dependencies"
  cd /app
  npm install &>>${LOG}
  status_check

  print_head "Configuring ${component} Service File"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
  status_check

  print_head "Reload SysyemD"
  systemctl daemon-reload &>>${LOG}
  status_check

  print_head "Enable ${component} Service"
  systemctl enable ${component} &>>${LOG}
  status_check

  print_head "Start ${component} Service"
  systemctl start ${component} &>>${LOG}
  status_check

  print_head "Configuring Mongodb Repo"
  cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
  status_check

  print_head "Install Mongodb Client"
  yum install mongodb-org-shell -y &>>${LOG}
  status_check

  print_head "Load Schema"
  mongo --host mongodb.roboshop.internal </app/schema/${component}.js &>>${LOG}
  status_check
}