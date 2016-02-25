#! /bin/sh
  # chkconfig: - 95 15

JBOSS_HOME="/opt/jboss/jboss-eap-5.1"
JBOSS_LOG_FILE="/home/dirman/custom/log/jboss_startup.log"
JBOSS_LOG2_FILE="/home/dirman/custom/log/jboss_stop.log"


start(){
        echo "Starting jboss.."

        
       nohup $JBOSS_HOME/jboss-as/bin/run.sh -Djboss.server.base.dir=/home/dirman/ -Djboss.server.base.url=file:/home/dirman/ -c custom -b 192.168.122.1 > $JBOSS_LOG_FILE 2> $JBOSS_LOG_FILE &
}

stop(){
        echo "Stopping jboss.."

        
      $JBOSS_HOME/jboss-as/bin/shutdown.sh -s jnp://192.168.122.1:1099 -u admin -p admin -S > $JBOSS_LOG2_FILE 2> $JBOSS_LOG2_FILE &
}




case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
    *)
        echo "Usage: jboss {start|stop}"
        exit 1
esac

exit 0
