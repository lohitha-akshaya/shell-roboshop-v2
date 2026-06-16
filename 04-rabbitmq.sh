# #!/bin/bash

source ./common.sh
check_root
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOG_FILE 
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOG_FILE
systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling and starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "setting up username and password"
print_total_time