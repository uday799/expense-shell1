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

dnf list installed mysql-server &>>LOG_FILE_NAME
if [ $? -ne 0 ]
then
dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "installing mysql"
else 
echo -e "mysql server alraedy $Y installed"
fi

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysqlserver"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysqlserver"

mysql -h database.udayops.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
VALIDATE $? "setting root password"
else
echo "root password already setup"
fi
