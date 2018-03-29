#!/bin/bash
############################################
#####   Ericom Shield Update           #####
###################################LO##BH###

#Check if we are root
if ((EUID != 0)); then
    #    sudo su
    echo "Usage: $0 [OPTIONS] COMMAND [ARGS]..."
    echo " Please run it as Root"
    echo "sudo $0 $@"
    exit
fi
ES_PATH="/usr/local/ericomshield"
ES_BACKUP_PATH="/usr/local/ericomshield/backup"
LOGFILE="$ES_PATH/ericomshield.log"
ES_VER_FILE="$ES_PATH/shield-version.txt"
ES_PRE_CHECK_FILE="$ES_PATH/shield-pre-install-check.sh"
ES_FORCE=false

ARGS="${@}"
if [ "$ARGS" = "" ]; then
   ARGS="update"
fi
if [ "$ARGS" = "-f" ]; then
   ARGS="update"
   ES_FORCE=true
fi

if [ ! -f "$ES_VER_FILE" ]; then
   echo "$(date): Ericom Shield Update: Cannot find version file" >>"$LOGFILE"
   exit 1
fi

if [ -f "$ES_PRE_CHECK_FILE" ] && [ "$ES_FORCE" == false ]; then
    source $ES_PRE_CHECK_FILE
    echo "***************     Running pre-install-check ..."
    perform_env_test
    if [ "$?" -ne "0" ]; then
       echo "$(date):FATAL:  Shield pre-install-check failed!"
       exit 1
    fi
fi

CONTAINER_TAG="$(grep -r 'shield-autoupdate' $ES_VER_FILE | cut -d' ' -f2)"
if [ "$CONTAINER_TAG" = "" ]; then
   CONTAINER_TAG="shield-autoupdate:180328-06.56-1731"
fi

echo "***************     Ericom Shield Update ($CONTAINER_TAG, $ARGS) ..."

echo "$(date): Ericom Shield Update: Running Update" >>"$LOGFILE"
docker run --rm -it \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v $(which docker):/usr/bin/docker \
   -v /usr/local/ericomshield:/usr/local/ericomshield \
    "securebrowsing/$CONTAINER_TAG" $ARGS
