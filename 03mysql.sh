#!/bin/bash

source ./common.sh
check_root
#installing  mysql
dnf install mysql-server -y   &>> $LOG_FILE
systemctl enable mysqld &>> $LOG_FILE
systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "Installing and starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting mysql root password"
print_total_time


