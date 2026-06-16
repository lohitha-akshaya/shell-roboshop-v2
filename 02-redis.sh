#!/bib/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"
B="\e[34m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d +%H:%M:%S")

#root access
USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e " $TIMESTAMP [ERROR]you are $B not $N $R root user $N,please run script with $R sudo $N or $R root $N access"
    exit 1
fi  

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R failed $N"
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 $G success $N"
    fi

}
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
