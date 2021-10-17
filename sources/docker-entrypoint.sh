#!/bin/bash
set -e

if [ ! "$(ls -A /opt/magic_mirror/modules)" ]; then
    cp -Rn /opt/default_modules/. /opt/magic_mirror/modules
fi

if [ ! "$(ls -A /opt/magic_mirror/config)" ]; then
    cp /tmp/mm-docker-config.js /opt/magic_mirror/config/config.js
fi

if [ ! "$(ls -A /opt/magic_mirror/css)" ]; then
    cp -Rn /opt/default_css/. /opt/magic_mirror/css
fi

if [ ! "$(ls -A /opt/magic_mirror/js)" ]; then
    cp -Rn /opt/default_js/. /opt/magic_mirror/js
fi

if [ -f "/opt/magic_mirror/config/config.js.template" ]; then
    envsubst < /opt/magic_mirror/config/config.js.template > /opt/magic_mirror/config/config.js
fi

magicmirror_root="/opt/magic_mirror"

module_deps=$DOCKER_MODULE_ADDITIONAL_DEPS
module_gits=$DOCKER_MODULE_INSTALL_GIT
module_install_cmd=$DOCKER_MODULE_INSTALL_CMD

if [[ ! -z $module_install_cmd ]]
then
    module_install_cmd="npm install"
fi

#create log file for post install logs
LOG_FILE="/opt/docker_post_install.log"
echo "" > $LOG_FILE
#install additional dependencies if required
if [ ! -z $module_deps ] #if deps is not empty we install, otherwise don't increase container size
then
    echo "--- INSTALLING EXTRA DEPS" >> $LOG_FILE
    apt-get update >> $LOG_FILE
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $module_deps   >> $LOG_FILE
fi

cd /opt/magic_mirror/modules
#module separator is ';'
if [[ ! -z $module_gits ]]
then
    echo "INSTALLING EXTRA MM Modules..." >> $LOG_FILE
    for module in $(echo $module_gits|sed -e "s/;/\n/g")
    do
        echo $module >> $LOG_FILE
         #get last part of the URL for the directories
        dir=$(echo "${module##*/}") #basically, all chars after the last '/'
        if [ ! -d $dir ]
        then
            git clone $module >> $LOG_FILE
        fi       
        cd $dir
        #we still reinstall it if they exists as this is needed anyway
        $module_install_cmd >> $LOG_FILE
        cd /opt/magic_mirror/modules/
        echo "----" >> $LOG_FILE
    done
fi

#failsafe, just in case we did not come back to root
#otherwise, docker CMD will not succeed
cd $magicmirror_root
echo "[DONE]"


exec "$@"
