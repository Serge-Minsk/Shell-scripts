#!/bin/bash

echo 'Fixing java -version issue'
#yum -y install glibc.i686
alternatives --config java <<< "2"

echo 'Modifying iptables'
chattr -i /etc/sysconfig/iptables
sed -i '/COMMIT/ a hello/' /etc/sysconfig/iptables
sed -i '$d' /etc/sysconfig/iptables
service iptables restart


echo 'Modifying vhost.conf'
sed -i '/<VirtualHost mntlab:80>/ a ServerName mntlab' /etc/httpd/conf.d/vhost.conf
sed -i 's/<VirtualHost mntlab:80>/<VirtualHost *:80>/' /etc/httpd/conf.d/vhost.conf

echo 'Modifying workers.properties'
sed -i 's/worker-{{ jkappname }}/tomcat.worker/' /etc/httpd/conf.d/workers.properties
sed -i 's/localhost/192.168.56.10/' /etc/httpd/conf.d/workers.properties

echo 'Restarting Appache and starting tomcat'
/etc/init.d/httpd graceful
/opt/apache/tomcat/7.0.62/bin/startup.sh

echo 'Fixing tomcat .bashrc issue'
sed -i '/export/d' /home/tomcat/.bashrc
sed -i '/export/d' /home/tomcat/.bashrc
chown -R tomcat:tomcat /opt/apache/tomcat/7.0.62/logs/
chkconfig tomcat on
