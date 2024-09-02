#!/bin/bash

USERID=$(id -u)
CHECK-ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "please run this command with root priveleges"
        exit 1
    fi
}

VALIDATE=(){
    if [ $1 -ne 0 ]
    then
        echo "$2 is Failed.."
    else
        echo "$2 is Success.."
    fi
}
echo "Script is started using at: $(date)"

CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing MySQL-Server"

systemctl enable mysqld  
VALIDATE $? "Enabling MySQL"

systemctl start mysqld
VALIDATE $? "Starting MySQL"

mysql -h manibhumaraju.online -u root -pExpenseApp@1 -e 'show databases;'
if [ $? -ne 0]
then
    echo "Mysql Root password is not set... creating now"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting MySQL Root Password"
else
    echo "MySQL Root Password is already Setup...SKIPPING" 
fi



