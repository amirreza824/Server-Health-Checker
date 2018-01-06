#!/bin/sh

#set -x
set -u



HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")
CALC="/usr/bin/bc"


FUN_TXT () {
  case $1 in
    ERR)
    echo -e "ERROR !!! \n on Server \"${HOSTNAME}\" , in Time: \"${DATE}\" \n $2 \n ";;
    WARN)
      echo -e "Warning !!! \n on Server \"${HOSTNAME}\" , in Time: \"${DATE}\" \n $2 \n ";;
    INFO)
      echo -e "Information ... \n on Server \"${HOSTNAME}\" , in Time: \"${DATE}\" \n $2 \n ";;
    esac

}



################################################################################
################################################################################
###################################  CGN  ######################################
################################################################################
################################################################################

LOG_TMP_FILE=$(mktemp -t LOG)
ps a

cat ${LOG_TMP_FILE}
##### Function Definitions Part .... ###########################################

FUN_LOG_CHK () {
  ps aux | grep -i "daemonlogger" | grep -v grep 1>&2 > /dev/null
  if [ $? -gt 0  ]; then
    FUN_TXT ERR "daemonlogger is not running !!!!!!!!!"
  else
#    LOG_NIC=$(cat ${LOG_TMP_FILE} | awk '{print $14}')

#    echo ${LOG_NIC}
echo hi
    #cat ${LOG_TMP_FILE} | awk '{print $16}' | while read line
    #  do
    #    ls -lt ${line}
    #    if [ $? != 0  ]; then
    #      FUN_TXT ERR "Directory \"${line}\" is Empty !!!!!!!!!"
    #    fi
    #    ls -lt ${line}/archive/
    #    if [ $? != 0  ]; then
    #      FUN_TXT ERR "Directory \"${line}\archive\" is Empty !!!!!!!!!"
    #    fi
    #  done
  fi

}


#FIXME: I will add : FUN_NIC_ERR ${LOG_NIC}


##### Checking Part .... #######################################################

FUN_LOG_CHK
#FUN_LOG_HF ## Checking file healthy


rm -rf $LOG_TMP_FILE
