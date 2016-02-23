yum -y install httpd httpd-devel
mkdir /usr/java && cd /usr/java
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz
tar -xzf jdk-8u74-linux-x64.tar.gz

sed -i.bak -e '/# User specific aliases and functions/ a\ export JAVA_HOME=/usr/java/jdk1.8.0_74' /home/tomcat/.bashrc
sed -i -e '/# User specific aliases and functions/ a\ export PATH=$PATH:$JAVA_HOME/bin' /home/tomcat/.bashrc

mkdir /tmp/mod_jk && cd /tmp/mod_jk
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz
tar -xzf tomcat-connectors-1.2.41-src.tar.gz
cd ./tomcat-connectors-1.2.41-src/native
./buildconf.sh
./configure --with-apxs=/usr/sbin/apxs
make
cp ./apache-2.0/mod_jk.so /usr/lib64/httpd/modules/
mkdir -p /opt/apache/tomcat/
cd /opt/apache/tomcat/
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz
tar -xzf apache-tomcat-8.0.32.tar.gz
mv apache-tomcat-8.0.32 8.0.32
ln -s /opt/apache/tomcat/8.0.32 /opt/apache/tomcat/current

chown -R tomcat:tomcat /opt/apache/tomcat/8.0.32
chmod +x /opt/apache/tomcat/8.0.32/bin/*.sh

cat << 'WORKERS' >> /etc/httpd/conf.d/workers.properties 
worker.list=worker1
worker.worker1.port=8009
worker.worker1.host=localhost
worker.worker1.type=ajp13
WORKERS

cat << 'VHOST' >> /etc/httpd/conf.d/vhost.conf
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf.d/workers.properties
JkMountCopy On
JkLogFile "/var/log/httpd/mod_jk.log"
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories +ForwardURIProxy
JkRequestLogFormat "%w %V %T"
  <VirtualHost *:80>
    JkMount /* worker1
  </VirtualHost>
VHOST
chkconfig httpd on

cat << 'TOMCAT' >> /etc/init.d/tomcat
#!/bin/sh

# chkconfig: 345 99 10
# description: apache tomcat auto start-stop script.

. /etc/init.d/functions

RETVAL=0

start()
{
  echo -n "Starting tomcat"
  su - tomcat -c "sh /opt/apache/tomcat/current/bin/startup.sh" > /dev/null
  success
  echo
}

stop()
{
  echo -n "Stopping tomcat"
  su - tomcat -c "sh /opt/apache/tomcat/current/bin/shutdown.sh" > /dev/null
  success
  echo
}

status()
{
  echo "tomcat is running"
}

case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
status)
        status
        ;;
restart)
        stop
        start
        ;;
*)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 1
esac
TOMCAT

chmod 755 /etc/init.d/tomcat
chkconfig tomcat on

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -m comment --comment "#webserver" -j ACCEPT
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited

iptables-save > /etc/sysconfig/iptables
/etc/init.d/tomcat start
/etc/init.d/httpd start
service iptables restart
