#!/bin/bash
# Based on http://serverfault.com/questions/425132/controlling-tomcat-with-supervisor

BISERVER_HOME=/srv/pentaho/biserver-ce

export JAVA_HOME=/usr/lib/jvm/java-7-oracle
export _PENTAHO_JAVA_HOME=$JAVA_HOME
export _PENTAHO_JAVA=$_PENTAHO_JAVA_HOME/bin/java

export CATALINA_HOME=$BISERVER_HOME/tomcat
export CATALINA_OPTS="-Djava.awt.headless=true -Xms1024m -Xmx2048m -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"
export CATALINA_PID=/var/run/catalina_pentaho.pid

# cleanup osgi cache to avoid strange exceptions (see http://stackoverflow.com/a/29368413)
rm -rf $BISERVER_HOME/pentaho-solutions/system/osgi/cache/*
# cleanup temp directory
rm -rf $CATALINA_HOME/temp/*

. $CATALINA_HOME/bin/catalina.sh start

function shutdown()
{
	$CATALINA_HOME/bin/catalina.sh stop
}

# Allow any signal which would kill a process to stop Tomcat
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP

wait $(cat $CATALINA_PID) 