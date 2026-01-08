#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOG_FOLDER=/var/log/expense-log
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME=$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log

VALIDATE() {

if [ $1 -ne 0 ]
then
echo -e  "$2... $R failure"
exit 1
else
echo -e "$2.. $G success"
fi

}

if [ $? -ne 0 ]
then
echo "you must have sudo access to execute this script pls try with sudo access"
exit 1
fi

echo "script started executing at : $TIMESTAMP"

dnf module disable nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "disabling default version"

dnf module enable nodejs:20 -y &>>LOG_FILE_NAME
VALIDATE $? "enabling 20 version"

dnf install nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "installing nodejs"

id expense
if [ $? -ne 0 ]
then
useradd expense &>>LOG_FILE_NAME
VALIADTE $? "adding expense user"
else
echo " user already created"
fi
mkdir -p /app &>>LOG_FILE_NAME
VALIDATE $? "directory craeted"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "downloading code"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>LOG_FILE_NAME
VALIDATE $? "Unzipping code"

npm install &>>LOG_FILE_NAME
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense-shell1/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>LOG_FILE_NAME
VALIDATE $? "installing mysql"

mysql -h database.udayops.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "loading schema"

systemctl daemon-reload &>>LOG_FILE_NAME
VALIDATE $? "reloading"

systemctl enable backend &>>LOG_FILE_NAME
VALIDATE $? "enabling backend"

systemctl restart backend &>>LOG_FILE_NAME
VALIADTE $? "restart backend"




