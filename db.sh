#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "enter the DB password"
read DB_PASSWORD

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILURE $N"
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run the script as a root user"
    exit 1
else
    echo "you are a super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "installation of MYSQL"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling of MYSQL"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting of MYSQL"

mysql db.rayudum.online -uroot -p${DB_PASSWORD} -e 'show database;'
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${DB_PASSWORD} &>>$LOGFILE
    VALIDATE $? "DB password has been set"
else
    echo "Password has been already set"
fi