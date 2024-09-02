#!/bin/bash

USERID=$(id -u)



CHECK_ROOT=(){
    if [ $USERID -ne 0 ]
    then
        echo "PLEASE RUN THIS COMMAND WIRH ROOT PRIVILEGES"
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 is....Failed"
        exit 1
    else
        echo "$2 is....Success"
    fi
}

CHECK_ROOT
dnf module disable nodejs -y
VALIDATE $? "Disableing nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"
id expense
if [ $? -ne 0 ]
then
    echo "Expense user is not exist...going to Creating"
    useradd expense
    VALIDATE $? "adding Expence user"
else
    echo "Expense user is already exist..Skipping"
fi

mkdir -p /app
VALIDATE $? "Creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloding Backend Code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Extracting Backend Code"

cd /app
npm install
cp /home/ec2-user/temp/backend.service /etc/systemd/system/backend.service

dnf install mysql -y
VALIDATE $? "Installing MySQL"



systemctl daemon-reload
VALIDATE $? ""