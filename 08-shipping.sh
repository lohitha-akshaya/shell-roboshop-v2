#!/bin/bash

app_name=shipping 
source ./common.sh
MYSQL_HOST=mysql.lohithadev.online
check_root
app_setup
java_Setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded"
else
    echo -e "Data already loaded ... $Y SKIPPING $N"
fi

restart_service
print_total_time