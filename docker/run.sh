#!/bin/bash

sleep 5

function check_install_mysql()
{
    #local HOST="mysql"

    local ROOT_PASS="$MYSQL_ENV_MYSQL_ROOT_PASSWORD"

    local USER_PASS="$MYSQL_ENV_MYSQL_PASSWORD"
    local USER_NAME="$MYSQL_ENV_MYSQL_USER"
    local USER_DB_NAME="$MYSQL_ENV_MYSQL_DATABASE"

    local VOLUME_HOME="/var/lib/mysql"
    local ZABBIX_MYSQL_V="/usr/share/zabbix-mysql"

    local cnt_tbl=`mysql -u$USER_NAME -p$USER_PASS -e "USE $USER_DB_NAME; SHOW TABLES; SELECT FOUND_ROWS();" | tail -n 1`

    #if [[ ! -d $VOLUME_HOME/$USER_DB_NAME ]]; then
    if [[ $cnt_tbl -eq 0 ]]; then
        echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
        #start_mysql

        #mysql_upgrade
        #echo "=> MySQL admin password: $ROOT_PASS"
        #mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$ROOT_PASS'"
        #mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
        #mysql -uroot -p$ROOT_PASS -e "CREATE DATABASE $USER_DB_NAME"

        #mysql -uroot -p$ROOT_PASS -e "CREATE USER '$USER_NAME'@'%' IDENTIFIED BY '$USER_PASS'"
        mysql -uroot -p$ROOT_PASS -e "CREATE USER '$USER_NAME'@'localhost' IDENTIFIED BY '$USER_PASS'"
        #mysql -uroot -p$ROOT_PASS -e "GRANT ALL PRIVILEGES ON $USER_DB_NAME.* TO '$USER_NAME'@'%'"
        mysql -uroot -p$ROOT_PASS -e "GRANT ALL PRIVILEGES ON $USER_DB_NAME.* TO '$USER_NAME'@'localhost'"

        echo "=> Executing Zabbix MySQL script files ..."
        mysql -u$USER_NAME -p$USER_PASS $USER_DB_NAME < "${ZABBIX_MYSQL_V}/schema.sql"
        mysql -u$USER_NAME -p$USER_PASS $USER_DB_NAME < "${ZABBIX_MYSQL_V}/images.sql"
        mysql -u$USER_NAME -p$USER_PASS $USER_DB_NAME < "${ZABBIX_MYSQL_V}/data.sql"
        echo "=> Done"

        #mysqladmin -uroot shutdown
        
        echo "=> Launched the process of setting the configuration files"
        sed -i 's/password="\*\*\*\*\*\*\*\*\*"/password="'$ROOT_PASS'"/' /root/.my.cnf
        
        sed -i 's/FROM="\*\*\*\*\*\*\*\*\*"/FROM="Zabbix Server <'$SEND_EMAIL_FROM'>"/' /usr/lib/zabbix/alertscripts/sm.sh
        sed -i 's/SMTP_SERVER=\*\*\*\*\*\*\*\*\*/SMTP_SERVER='$SEND_EMAIL_SMTP_SERVER'/' /usr/lib/zabbix/alertscripts/sm.sh
        sed -i 's/SMTP_LOGIN=\*\*\*\*\*\*\*\*\*/SMTP_LOGIN='$SEND_EMAIL_SMTP_LOGIN'/' /usr/lib/zabbix/alertscripts/sm.sh
        sed -i 's/SMTP_PASSWORD=\*\*\*\*\*\*\*\*\*/SMTP_PASSWORD='$SEND_EMAIL_SMTP_PASSWORD'/' /usr/lib/zabbix/alertscripts/sm.sh
	
	sed -i 's/allow \*\*\*\*\*\*\*\*\*:\*\*\*\*\*\*\*\*\*/allow '$MONIT_WEB_USER':'$MONIT_WEB_PASSWORD'/' /etc/monitrc
        
        sed -i 's/DBHost=\*\*\*\*\*\*\*\*\*/DBHost='$DBHost'/' /etc/zabbix/zabbix_server_db.conf
        sed -i 's/DBName=\*\*\*\*\*\*\*\*\*/DBName='$USER_DB_NAME'/' /etc/zabbix/zabbix_server_db.conf
        sed -i 's/DBUser=\*\*\*\*\*\*\*\*\*/DBUser='$USER_NAME'/' /etc/zabbix/zabbix_server_db.conf
        sed -i 's/DBPassword=\*\*\*\*\*\*\*\*\*/DBPassword='$USER_PASS'/' /etc/zabbix/zabbix_server_db.conf
        echo "=> Done"
    else
        echo "=> Using an existing volume of MySQL"
    fi
}

check_install_mysql

echo "=> localedef ru_RU.UTF-8"
localedef -v -c -i ru_RU -f UTF-8 ru_RU.UTF-8

echo "=> Executing Monit..."
chmod 700 /etc/monitrc
#export TERM=xterm
exec monit -d 10 -Ic /etc/monitrc