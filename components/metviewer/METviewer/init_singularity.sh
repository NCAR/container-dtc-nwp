#!/bin/sh

DATADIR="/var/lib/mysql"
MYSQL_ROOT_PASSWORD='mvuser'

tempSqlFile=$HOME/mysql-first-time.sql

echo 'Running mysql_install_db ...'
		mysql_install_db --datadir="$DATADIR"
		echo 'Finished mysql_install_db'

# create database init file in the home directory
# this file initialises root user
cat > "$tempSqlFile" <<-EOSQL
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
		EOSQL
echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"


# start database with created init fire
exec mysqld_safe --init-file="$tempSqlFile" &

# start Tomcat
exec /opt/tomcat/bin/startup.sh &
