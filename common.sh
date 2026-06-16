#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
P="\e[35m"
B="\e[34m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d +%H:%M:%S")

echo -e "$TIMESTAMP [INFO] Script execution started"

#root access
USERID=$(id -u)

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $TIMESTAMP [ERROR]you are $B not $N $R root user $N,please run script with $R sudo $N or $R root $N access"
        exit 1
    fi  
}

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R failed $N"
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 $G success $N"
    fi

}

print_total_time(){
    echo -e "$TIMESTAMP[INFO] Script executed in $G $SECONDS $N seconds"
}

app_setup(){
        id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    rm -rf /app
    VALIDATE $? "Removing existing code"

    rm -rf /tmp/$app_name.zip
    VALIDATE $? "Removed $app_name zip"

    mkdir -p /app  &>>$LOG_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Downloaded and extracted $app_name code"
}  
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    dnf module enable nodejs:20 -y  &>>$LOG_FILE
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS:20"


    npm install  &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}  
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Created systemctl service"
    systemctl deamon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enabling $app_name service"
}
restart_service(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restarting $app_name service"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"
}
python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python"
    pip3 install -r requirements.txt  &>>$LOG_FILE
    VALIDATE $? "Installing dependencies" 
}
