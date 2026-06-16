#!/bib/bash

source ./common.sh
check_root
#installing redis
dnf module disable redis -y  &>> $LOG_FILE
dnf module enable redis:7 -y  &>> $LOG_FILE
dnf install redis -y   &>> $LOG_FILE
VALIDATE $? "Installing redis"

# changing bind IP and protected mode
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/c protected-mode no' -i /etc/redis/redis.conf
VALIDATE $? "Allowing remote access "

#starting and enabling redis
systemctl enable redis &>> $LOG_FILE
systemctl start redis  &>> $LOG_FILE
VALIDATE $? "Starting and enabling redis"
print_total_time
