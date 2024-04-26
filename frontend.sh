#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
    if [$1 -ne 0 ]
    then
        echo -e "$2 .....$R FAILURE $N"
        exit 1
    else
        echo -e "$2 .....$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0]
then
    echo "Please run the script as a root user"
    exit 1
else
    echo "you are a super user"
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Donwloading frontend code zip file"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "extracting front end code"

cp                                       /etc/nginx/default.d/expese.conf &>>$LOGFILE
VALIDATE $? "Creating Nginx Reverse Proxy Configuration"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"

