#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


CHECK_ROOT=(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R PLEASE RUN THIS COMMAND WIRH ROOT PRIVILEGES $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is....$R Failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is....$G Success $N" | tee -a $LOG_FILE
    fi
}

CHECK_ROOT
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disableing nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"
id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "Expense user is not exist...going to Creating" &>>$LOG_FILE
    useradd expense &>>$LOG_FILE
    VALIDATE $? "adding Expence user"
else
    echo "Expense user is already exist..$Y Skipping $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloding Backend Code"

cd /app &>>$LOG_FILE
rm -rf /app/* &>>$LOG_FILE
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting Backend Code"

cd /app &>>$LOG_FILE
npm install &>>$LOG_FILE
cp /home/ec2-user/temp/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Loading Schema"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon Reloded"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enable Backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restart Backend"