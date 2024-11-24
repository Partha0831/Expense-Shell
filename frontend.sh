#!/bin/bash

USERID=$(id -u)

LOG_Folder="/var/log/Expense-shell"
Log_File=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
File_Name="$LOG_Folder/$Log_File-$TIMESTAMP.log"
mkdir -p $LOG_Folder

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run Script with Root Credential $N " &>>$File_Name
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...is $R failed $N " | tee -a $File_Name
    else
        echo -e "$2...is $G Success $N " | tee -a $File_Name
    fi
}

echo "Script started at : $(date)" | tee -a $File_Name

 CHECK_ROOT

dnf install nginx -y &>>$File_Name
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$File_Name
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$File_Name
VALIDATE $? "starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$File_Name

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$File_Name
VALIDATE $? "Downloading Frontend Code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$File_Name
VALIDATE $? "Unzipping Downloaded Frontend Code"

cp /git/Expense-Shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$File_Name
VALIDATE $? "restarting nginx"


