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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Nodejs disabling"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "ENABLING Of new version of nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating user expense"
else
    echo "user  expense already exist"
fi

mkdir /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend code"

cd /app 
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzipping backend code"

npn install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying backend.service to system"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading deamon"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

mysql -h 172.31.16.18 -uroot -p${DB_PASSWORD} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend"


