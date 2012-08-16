#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This software is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install mysql (put it up front because it has an interactive prompt)

echo "==============================================================="
echo "install_mysql.sh"
echo "==============================================================="


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

#set the root password without the need for interaction
PASSWORD="user"

# pre-seed answers to installer questions:
cat << EOF | debconf-set-selections
mysql-server-5.5  mysql-server/root_password  password $PASSWORD
mysql-server-5.5  mysql-server/root_password  seen true
mysql-server-5.5  mysql-server/root_password_again  password $PASSWORD
mysql-server-5.5  mysql-server/root_password_again  seen true
EOF

#apt-get install --yes mysql-server mysql-admin
apt-get install --yes mysql-server

## just to be sure if mysql server is running

#debug:
echo "--- before"
ps -ef | grep mysql
echo "---"

## check if mysql is running and do appropriate action
if [ `pgrep -cf '/usr/sbin/mysqld'` -eq 0 ] ; then
    echo "Starting mysql.."
    service mysql start 2>&1
    echo $?
else
    echo "Restarting mysql.."
    service mysql restart 2>&1
    echo $?
fi

### debugging
echo "There are `ps aux | grep -c '[m]ysql'` mysqld's running"

echo "=== after"
ps -ef | grep mysql
echo "==="

# dpkg -l:
#   installed ok: mysql-server
#   not installed: phpmyadmin
ls -l /var/log/mysql*
tail /var/log/syslog
#chmod 775 /var/lib/mysql
ls -l /var/lib/mysql
ls -la /var/run/mysqld

#perhaps this is needed:  ???
#chown mysql.mysql /var/run/mysqld -R 

ls -l /var/run/mysqld/mysqld.sock
#it's a socket created when mysql starts:
#   touch /var/run/mysqld/mysqld.sock
#ls -l /var/run/mysqld/mysqld.sock
#chmod 775 /var/run/mysqld/mysqld.sock
#ls -l /var/run/mysqld/mysqld.sock
#doesn't exist: tail -n 30 /var/log/mysql/error.log
echo "try for another restart"
/etc/init.d/mysql status 2>&1
echo $?
/etc/init.d/mysql restart 2>&1
echo $?
mysqlcheck -A -uroot -puser --verbose

# to be continued:
#   see http://ubuntuforums.org/showthread.php?t=804021&page=5
# try 
grep bind-address /etc/mysql/*.cnf
nsloopup localhost
grep run /etc/apparmor.d/usr.sbin.mysqld
#"""
#The problem was caused by the apparmor daemon.
#I just changed the lines in /etc/apparmor.d/usr.sbin.mysqld
#- /var/run/mysqld/mysqld.pid w,
#- /var/run/mysqld/mysqld.sock w,
#to
#+ /{,var/}run/mysqld/mysqld.pid w,
#+ /{,var/}run/mysqld/mysqld.sock w,
#and restarted appamor daemnon with
#/etc/init.d/appamor restart
#After restarting mysql daemon everthing works fine
#/etc/init.d/mysql restart
#"""
echo "..on with the show.."
### end of debugging


#if needed: sudo mysqladmin password newpassword

## well maybe that didn't work, let's see...
#MSQL_CONF_FILE=/etc/mysql/debian.cnf
#MSQL_CONF_FILE=/etc/mysql/my.cnf
#MYSQL_ADMIN_NM=`grep -w '^user' "$MSQL_CONF_FILE" | head -n 1 | cut -f2 -d'=' | awk '{print $1}'`
MYSQL_ADMIN_NM=root

#MYSQL_ADMIN_PW=`grep -w '^password' "$MSQL_CONF_FILE" | head -n 1 | cut -f2 -d'=' | awk '{print $1}'`
MYSQL_ADMIN_PW="$PASSWORD"
#echo ".. MySQL admin name is <$MYSQL_ADMIN_NM>. (see $MSQL_CONF_FILE)"

#debug
#echo "=== /etc/mysql/debian.cnf ==="
#cat /etc/mysql/debian.cnf
#echo "============================="

echo "
CREATE USER '$USER_NAME'@'localhost' IDENTIFIED BY '$USER_NAME';
GRANT ALL PRIVILEGES ON *.* TO '$USER_NAME'@'localhost' WITH GRANT OPTION;
" | mysql -u"$MYSQL_ADMIN_NM" -p"$MYSQL_ADMIN_PW"

###
#argh it's still broken. stupid hack to get it to work
cp ../app-conf/ushahidi/rc.go_mysql /etc
chmod u+rx,go-rx /usr/local/sbin/rc.go_mysql
cp /etc/init.d/rc.local /etc/init.d/rc.go_mysql
sed -i -e 's/rc\.local/rc.go_mysql/' /etc/init.d/rc.go_mysql
ln -s /etc/init.d/rc.go_mysql /etc/rc2.d/S99rc.go_mysql
###


exit 0

##########################################################################
# MySqlAdmin GUI is not longer maintained.
# Replacement:
#    MySql-Workbench: Wants 21mb compressed, or 62mb uncompressed, disc space.
apt-get --assume-yes install mysql-workbench ttf-bitstream-vera
