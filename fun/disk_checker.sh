#!/bin/sh

#set -x
set -u


HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")
CALC="/usr/bin/bc"
ZFS_APP="/sbin/zfs"
ZPOOL_APP="/sbin/zpool"

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
###################################  HDD  ######################################
################################################################################
################################################################################



HDDALERT=70
EXCLUDE_PART="Filesystem|devfs|fdescfs" # exp: EXCLUDE_PART="/dev/da0|/dev/db1"

##### Function Definitions Part .... ###########################################

HDD_FUN () {
    while read line
      do
        usage=$(echo $line | awk '{ print $1}' | cut -d'%' -f1)
        partition="$(echo $line | awk '{print $2}')"
        if [ $usage -ge $HDDALERT ] ; then
          FUN_TXT ERR "Running out of space ${partition} ${usage}%"
        fi
      done
}


FUN_ZFS_CHK () {

  kldstat -m zfs 1>&2 > /dev/null
  if [ $? -lt 1 ]; then
    ${ZPOOL_APP} status | grep "unrecoverable" 1>&2 > /dev/null
      if [ $? -lt 1 ]; then
        FUN_TXT WARN "We have Error on ZFS !!!!"
      fi
  fi

}

##### Checking Part .... #######################################################


df -H | grep -vE '(Filesystem|devfs|fdescfs)' | awk '{print $5 " " $6}' | HDD_FUN


#FIXME: Add Hdd error detection on all logs - ZFS , RAID Controller , ...

#FUN_ZFS_CHK
