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
        echo -e "$RPlease run Script with Root Credential $N " &>>$File_Name
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


 CHECK_ROOT

 dnf install mysql-server -y &>>$File_Name
VALIDATE $? "Mysql-Server Installation"

systemctl enable mysqld &>>$File_Name
VALIDATE $? "Mysql-Server enable"

systemctl start mysqld &>>$File_Name
VALIDATE $? "Mysql-Server Starting"



mysql -h mysql.devopspractice.in -u root -pExpenseApp@1 -e 'show databases;' &>>$File_Name

if [$?-ne 0 ]
then 
echo "MySQL root $R password is not setup $N,$G setting now $N" &>>$File_Name
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$File_Name
VALIDATE $? "Mysql-Server password setting"
else
echo "Mysql root password is$G already set $N"
fi