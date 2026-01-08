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
mkdir -p $LOGS_FOLDER

dnf install nginx -y
VALIDATE $? "INSTALLING NGINX

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Nginx server"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing existing code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading Latest code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping the frontend code"

cp /home/ec2-user/expense-shell1/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting nginx"

