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

dnf module disable nodejs -y &>>$File_Name
VALIDATE $? "Disabling Node JS"

dnf module enable nodejs:20 -y &>>$File_Name
VALIDATE $? "Enabling Node JS:20"

dnf install nodejs -y &>>$File_Name
VALIDATE $? "Installing Node JS"

id expense &>>$File_Name

if [ $? -ne 0 ]
then
echo -e "there is not user with name expense.. $G Adding Now $N"
useradd expense
VALIDATE $? "useradd expense"
else
echo -e "User Expense is $G Exists $N"
fi

mkdir -p /app &>>$File_Name
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$File_Name
VALIDATE $? "Downloading Code to temp"

cd /app &>>$File_Name
rm -rf /app/* 

unzip /tmp/backend.zip &>>$File_Name
VALIDATE $? "Unzipping the Downloaded Code to App Directory"

npm install &>>$File_Name
VALIDATE $? "Npm Installation"
cp /git/Expense-Shell/backend.service /etc/systemd/system/backend.service &>>$File_Name

dnf install mysql -y &>>$File_Name
VALIDATE $? "mysql client Installation"

mysql -h mysql.devopspractice.in -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$File_Name
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$File_Name
VALIDATE $? "daemon-reload"

systemctl start backend &>>$File_Name
VALIDATE $? "start backend"

systemctl enable backend &>>$File_Name
VALIDATE $? "enable backend"

systemctl restart backend &>>$File_Name
VALIDATE $? "restart backend"
