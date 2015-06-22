#!/bin/bash

sleep 5

function check_install_mysql()
{
    local VOLUME_HOME="/var/lib/mysql"

    if [[ ! -d $VOLUME_HOME/zabbix ]]; then
        echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
        #start_mysql

        #mysql_upgrade
        local HOST="mysql"
        local PASS="$MYSQL_ROOT_PASSWORD"
        echo "=> MySQL admin password: $PASS"
        #mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
        #mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
        mysql -uroot -p$PASS -e "CREATE DATABASE zabbix"

        echo "=> Executing Zabbix MySQL script files ..."
        local ZABBIX_MYSQL_V="/usr/share/zabbix-mysql"
        mysql -uroot -p$PASS zabbix < "${ZABBIX_MYSQL_V}/schema.sql"
        mysql -uroot -p$PASS zabbix < "${ZABBIX_MYSQL_V}/images.sql"
        mysql -uroot -p$PASS zabbix < "${ZABBIX_MYSQL_V}/data.sql"
        echo "=> Done"

        mysql -uroot -p$PASS -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY '$PASS'"
        mysql -uroot -p$PASS -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '$PASS'"
        mysql -uroot -p$PASS -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%'"
        mysql -uroot -p$PASS -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'"

        #mysqladmin -uroot shutdown
    else
        echo "=> Using an existing volume of MySQL"
    fi
}

check_install_mysql

echo "=> localedef ru_RU.UTF-8"
localedef -v -c -i ru_RU -f UTF-8 ru_RU.UTF-8

echo "=> Executing Monit..."
chmod 700 /etc/monitrc
export TERM=xterm
exec monit -d 10 -Ic /etc/monitrc