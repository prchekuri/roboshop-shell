script_location=$(pwd)
LOG=/tmp/roboshop.log

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