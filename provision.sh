#!/bin/bash

function comment {
cat << EOF | tee -a /vagrant/log_provision
$1
EOF
}

function log_inst {
if [ $? -eq 0 ]
then
TS=$(date +"%d/%m/%Y %H:%M:%S")
cat << EOF | tee -a /vagrant/log_provision
$TS | Success | $1
EOF
else
TS=$(date +"%d/%m/%Y %H:%M:%S")
cat << EOF | tee -a /vagrant/log_provision
$TS | Fail | $1
EOF
fi
}

if [ -f /vagrant/log_provision ]
then
cat /dev/null > /vagrant/log_provision
fi


comment "LOG FILE OF PROVISION"
mkdir ~/download

comment "	-==# Download, install and configure Oracle JDK 1.7 #==-"
if [ -f /vagrant/jdk-7u79-linux-x64.rpm ]
then
cp /vagrant/jdk-7u79-linux-x64.rpm ~/download/
log_inst "Copy Oracle JDK 1.7 from /vagrant"
else
wget -P ~/download/ --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"
log_inst "Download Oracle JDK 1.7"
fi
rpm -ivh ~/download/jdk-7u79-linux-x64.rpm
log_inst "Install Oracle JDK 1.7 (rpm)"

comment "	-==# Install Git #==-"
yum install -y git-core
log_inst "Install Git (yum)"

comment "	-==# Download and configure Apache Tomcat #==-"
if [ -f /vagrant/apache-tomcat-7.0.68.tar.gz ]
then
cp /vagrant/apache-tomcat-7.0.68.tar.gz ~/download/
log_inst "Copy Apache Tomcat 7 from /vagrant"
else
wget -P ~/download/ http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz
log_inst "Download Apache Tomcat 7"
fi
tar -xf ~/download/apache-tomcat-7.0.68.tar.gz -C /opt/
log_inst "Extract Apache Tomcat 7 archive to /opt"
sed -i 's/Connector port="8080"/Connector port="8280"/' /opt/apache-tomcat-7.0.68/conf/server.xml
log_inst "Change Apache Tomcat configuration (HTTP connector port='8280')"
sed -i 's/Connector port="8009"/Connector port="8209"/' /opt/apache-tomcat-7.0.68/conf/server.xml
log_inst "Change Apache Tomcat configuration (AJP connector port='8209')"
sed -i 's/Engine name="Catalina" defaultHost="localhost"/Engine name="Catalina" defaultHost="127.0.0.3"/' /opt/apache-tomcat-7.0.68/conf/server.xml

useradd -p 'XhZN8l0yIlYY6' tomcat
log_inst "Create user 'tomcat'"
chown -R tomcat:tomcat /opt/apache-tomcat-7.0.68
log_inst "Change the owner of /opt/apache-tomcat-7.0.68 to user 'tomcat'"
cat << 'EOF' > /etc/init.d/tomcat
#!/bin/sh
# chkconfig: 345 99 10
# description: apache tomcat auto start-stop script.
. /etc/init.d/functions
RETVAL=0
start()
{
echo -n "Starting tomcat"
su - tomcat -c "sh /opt/apache-tomcat-7.0.68/bin/startup.sh"
success
echo
}
stop()
{
echo -n "Stopping tomcat"
su - tomcat -c "sh /opt/apache-tomcat-7.0.68/bin/shutdown.sh"
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
EOF
log_inst "Create init script for Apache Tomcat 7"
chmod +x /etc/init.d/tomcat
log_inst "Add executable prtmission to tomcat init script"
chkconfig --add tomcat
log_inst "Add tomcat to chkconfig"
chkconfig tomcat on
log_inst "Switch chkconfig tomcat on"
service tomcat start
log_inst "Start Apache Tomcat service"

comment "	-==# Download, install and configure Apache Maven 3.3.9 #==-"
wget -P ~/download/ http://ftp.byfly.by/pub/apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
log_inst "Apache Maven 3.3.9"
tar xf ~/download/apache-maven-3.3.9-bin.tar.gz -C /opt/
log_inst "Extract Apache Maven 3.3.9 archive to /opt"
cat << 'EOF' >> /etc/profile
export PATH=$PATH:/opt/apache-maven-3.3.9/bin
EOF
log_inst "Add the bin directory of the apache-maven-3.3.9 directory to the PATH environment variable"
source /etc/profile
log_inst "source /etc/profile"

comment "	-==# Install and configure Jenkins #==-"
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
log_inst "Add Jenkins repository"
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
log_inst "Import key"
if [ -f /vagrant/jenkins-1.642.4-1.1.noarch.rpm ]
then
cp /vagrant/jenkins-1.642.4-1.1.noarch.rpm ~/download/
log_inst "Copy Jenkins 1.642.4 from /vagrant"
rpm -ivh ~/download/jenkins-1.642.4-1.1.noarch.rpm
log_inst "Install Jenkins 1.642.4 (rpm)"
else
yum -y install jenkins-1.642.4-1.1.noarch
log_inst "Install Jenkins 1.642.4 (yum)"
fi
sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8180"/' /etc/sysconfig/jenkins
log_inst "Change Jenkins configuration (JENKINS_PORT='8180')"
sed -i 's/JENKINS_LISTEN_ADDRESS=""/JENKINS_LISTEN_ADDRESS="127.0.0.2"/' /etc/sysconfig/jenkins
log_inst "Change Jenkins configuration (JENKINS_LISTEN_ADDRESS='127.0.0.2')"
sed -i 's/JENKINS_AJP_PORT="8009"/JENKINS_AJP_PORT="8109"/' /etc/sysconfig/jenkins
log_inst "Change Jenkins configuration (JENKINS_AJP_PORT='8109')"
sed -i 's/JENKINS_AJP_LISTEN_ADDRESS=""/JENKINS_AJP_LISTEN_ADDRESS="127.0.0.2"/' /etc/sysconfig/jenkins
log_inst "Change Jenkins configuration (JENKINS_AJP_LISTEN_ADDRESS='127.0.0.2')"
sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="--prefix=\/jenkins"/' /etc/sysconfig/jenkins
log_inst "Change Jenkins configuration (JENKINS_ARGS='--prefix=/jenkins')"
cp -f /vagrant/config.xml /var/lib/jenkins
log_inst "Replace config.xml file in /var/lib/jenkins"
cat << 'EOF' > /var/lib/jenkins/hudson.tasks.Maven.xml
<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>Apache Maven 3.3.9</name>
      <home>/opt/apache-maven-3.3.9</home>
      <properties/>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>
EOF
log_inst "Create file /var/lib/jenkins/hudson.tasks.Maven.xml"
chown -R jenkins:jenkins /var/lib/jenkins
log_inst "Change the owner of /var/lib/jenkins to user 'jenkins'"
service jenkins start
log_inst "Start Jenkins service"
sleep 10
service jenkins stop
log_inst "Stop Jenkins service"
if [ -e /vagrant/icon-shim.hpi ]
then
cp /vagrant/icon-shim.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'icon-shim' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/icon-shim/2.0.3/icon-shim.hpi
log_inst "Download plugin 'icon-shim' for Jenkins from the internet"
fi
if [ -e /vagrant/credentials.hpi ]
then
cp /vagrant/credentials.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'credentials' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/credentials/1.26/credentials.hpi
log_inst "Download plugin 'credentials' for Jenkins from the internet"
fi
if [ -e /vagrant/ssh-credentials.hpi ]
then
cp /vagrant/ssh-credentials.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'ssh-credentials' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/ssh-credentials/1.11/ssh-credentials.hpi
log_inst "Download plugin 'ssh-credentials' for Jenkins from the internet"
fi
if [ -e /vagrant/git-client.hpi ]
then
cp /vagrant/git-client.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'git-client' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/git-client/1.19.6/git-client.hpi
log_inst "Download plugin 'git-client' for Jenkins from the internet"
fi
if [ -e /vagrant/junit.hpi ]
then
cp /vagrant/junit.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'junit' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/junit/1.11/junit.hpi
log_inst "Download plugin 'junit' for Jenkins from the internet"
fi
if [ -e /vagrant/matrix-project.hpi ]
then
cp /vagrant/matrix-project.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'matrix-project' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/matrix-project/1.6/matrix-project.hpi
log_inst "Download plugin 'matrix-project' for Jenkins from the internet"
fi
if [ -e /vagrant/scm-api.hpi ]
then
cp /vagrant/scm-api.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'scm-api' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins https://updates.jenkins-ci.org/download/plugins/scm-api/1.1/scm-api.hpi
log_inst "Download plugin 'scm-api' for Jenkins from the internet"
fi
if [ -e /vagrant/mailer.hpi ]
then
cp /vagrant/mailer.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'mailer' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/mailer/1.16/mailer.hpi
log_inst "Download plugin 'mailer' for Jenkins from the internet"
fi
if [ -e /vagrant/git.hpi ]
then
cp /vagrant/git.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'git' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/git/2.4.4/git.hpi
log_inst "Download plugin 'git' for Jenkins from the internet"
fi
if [ -e /vagrant/delivery-pipeline-plugin.hpi ]
then
cp /vagrant/delivery-pipeline-plugin.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'delivery-pipeline-plugin' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/delivery-pipeline-plugin/0.9.9/delivery-pipeline-plugin.hpi
log_inst "Download plugin 'delivery-pipeline-plugin' for Jenkins from the internet"
fi
if [ -e /vagrant/parameterized-trigger.hpi ]
then
cp /vagrant/parameterized-trigger.hpi /var/lib/jenkins/plugins/
log_inst "Copy plugin 'parameterized-trigger' for Jenkins from /vagrant"
else
wget -P /var/lib/jenkins/plugins/ https://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.30/parameterized-trigger.hpi
log_inst "Download plugin 'parameterized-trigger' for Jenkins from the internet"
fi
cp -R /vagrant/jobs/build/ /var/lib/jenkins/jobs/
log_inst "Copy 'build' job to Jenkins"
cp -R /vagrant/jobs/deploy/ /var/lib/jenkins/jobs/
log_inst "Copy 'deploy' job to Jenkins"
chown -R jenkins:jenkins /var/lib/jenkins
log_inst "Change the owner of /var/lib/jenkins to user 'jenkins'"
sleep 10
service jenkins start
log_inst "Start Jenkins and deploy plugins"
cat << 'EOF' > /etc/sudoers.d/jenkins
Defaults:jenkins !requiretty
jenkins    ALL=(ALL)    NOPASSWD:ALL
EOF
log_inst "Create file /etc/sudoers.d/jenkins"

comment "	-==# Install and configure Nginx #==-"
cat << 'EOF' > /etc/yum.repos.d/NGINX.repo
[NGINX]
name=NGINX repo
baseurl=http://NGINX.org/packages/centos/6/$basearch/
gpgcheck=0
enabled=1
EOF
log_inst "Create file /etc/yum.repos.d/NGINX.repo"
if [ -f /vagrant/nginx-1.8.1*.rpm ]
then
sed -i 's/gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/NGINX.repo
log_inst "Replace 'gpgcheck=0' with 'gpgcheck=1' in the file NGINX.repo"
cp /vagrant/nginx_signing.key ~/download/
log_inst "Copy Nginx signing key from /vagrant"
rpm --import ~/download/nginx_signing.key
log_inst "Import key"
cp /vagrant/nginx-1.8.1*.rpm ~/download/
log_inst "Copy Nginx 1.8.1 from /vagrant"
rpm -ivh ~/download/nginx-1.8.1*.rpm
log_inst "Install Nginx 1.8.1 (rpm)"
else
yum install -y nginx-1.8.1
log_inst "Install Nginx 1.8.1 (yum)"
fi
cat << 'EOF' > /etc/nginx/conf.d/additional.conf
server {

    listen 8080;

    location /jenkins/ {
        proxy_pass http://127.0.0.2:8180/jenkins/;
    }

    location / {
        proxy_pass http://127.0.0.3:8280/;
        proxy_redirect off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

EOF
log_inst "Create configuration file for Jenkins and Apache Tomcat proxy"
service nginx start
log_inst "Start Nginx service"

comment "	-==# Delete folder /vagrant/download #==-"
rm -rf /vagrant/download
log_inst "Delete download folder"

comment "	-==# END #==-"
