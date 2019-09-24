#!/bin/ksh

MV_PROP=/opt/tomcat/webapps/metviewer/WEB-INF/classes/mvservlet.properties

# Strip off existing url.output line
cat ${MV_PROP} | egrep -v url.output > ${MV_PROP}-NEW

# Get public ip address:
IP_ADDRESS=`curl ifconfig.me`
echo "Resetting METviewer URL to http://${IP_ADDRESS}/metviewer/metviewer1.jsp"

# Add new url.output line
echo "url.output=http://${IP_ADDRESS}/metviewer_output/" >> ${MV_PROP}-NEW

# Overwrite properties file
mv ${MV_PROP}-NEW ${MV_PROP}

# Restart Tomcat
echo "Restarting METviewer web service"
/opt/tomcat/bin/shutdown.sh
sleep 2
/opt/tomcat/bin/startup.sh

