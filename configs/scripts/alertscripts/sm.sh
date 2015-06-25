#!/bin/sh


# poluchenie dannyh iz Zabbix
export MAILTO=$1
export SUBJECT=$2
export TEXT=$3

# ot kogo budet prihodit' pis'mo
export FROM="*********"

# avtorizacija na udalennom SMTP servere
export SMTP_SERVER=*********
export SMTP_LOGIN=*********
export SMTP_PASSWORD=*********

# otpravka soobshhenija (dlja avtorizacii ispol'zuetsja 25 port)
# -o message-charset=UTF8, chtoby soobshhenija prihodili po-russki
/usr/local/bin/sendEmail -f "$FROM" -t "$MAILTO" -u "$SUBJECT" -m "$TEXT" -o message-charset=UTF8 -s $SMTP_SERVER:25 -xu $SMTP_LOGIN -xp $SMTP_PASSWORD