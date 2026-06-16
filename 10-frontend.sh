#!/bin/bash

app_name=frontend
source ./common.sh
check_root

dnf module disable nginx -y &>> $LOG_FILE
dnf module enable nginx:1.24 -y &>> $LOG_FILE
dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removed Default code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Downloaded and extracted frontend code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removed Default conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied roboshop nginx conf"

systemctl restart nginx
systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabled and restarted nginx"
print_total_time