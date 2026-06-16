#!/bib/bash

#calling common.sh
source ./common.sh

check_root

#MONGO DB
cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE  $? "Adding Mongo repo"

#installing mongo db
dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "Installing Mongodb"

#starting and enabling mongodb
systemctl enable --now mongod   &>> $LOG_FILE
VALIDATE $? "Starting  and enabling mongodb"

#changing bind IP 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connection to mongodb"

#restarting mongodb
systemctl restart mongod
VALIDATE $? "Restarting mongodb"

print_total_time


   