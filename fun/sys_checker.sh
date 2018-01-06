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
###################################  CPU  ######################################
################################################################################
################################################################################

#system has been up, the number of users, and the load average of the
#system over the last 1, 5, and 15 minutes.

DATE_APP='/bin/date'
DATESEC=$(${DATE_APP} +%s)
DATEBOOT=$(${DATE_APP} -r /var/run/dmesg.boot +%s)
UPTIME=$((${DATESEC} - ${DATEBOOT}))
SRV_MUST_UP="2" # server have to be UP in days
WHO="/usr/bin/who"

PS_APP='/bin/ps'
SYSCTL_APP='/sbin/sysctl'
SYSCTL_TMP=$(mktemp -t SYS)
${SYSCTL_APP} -a > ${SYSCTL_TMP}

##### Function Definitions Part .... ###########################################


FUN_SYS_TTY () {

  ${WHO} | grep -i "ttyv" 1>&2 > /dev/null
  if [ $? -lt 1 ]; then
    FUN_TXT WARN "Someone logined to Server Consol !!!!"
  fi
}

FUN_SYS_UPTIME () {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))

#REF:http://www.cplusplus.com/reference/cstdio/printf/

  [ $D -gt 0 ] && printf '%d days ' $D
  [ $H -gt 0 ] && printf '%d hours ' $H
  [ $M -gt 0 ] && printf '%d minutes ' $M
  [ $D -gt 0 ] || [ $H -gt 0 ] || [ $M -gt 0 ] && printf 'and '

  printf '%d seconds\n' $S

  local CHECKER=$((SRV_MUST_UP*60*60*24))
  if [ $1 -lt ${CHECKER} ]; then
    FUN_TXT WARN "Server was Rebooted in ${SRV_MUST_UP} days ago !!!"
  fi

}


FUN_KRN_NAME () {

  OS_INFO=$(cat ${SYSCTL_TMP} | grep kern.version | head -n1 | awk '{print $2 " " $3}')
  KRN_INFO=$(cat ${SYSCTL_TMP} | grep kern.version | head -n1 | awk '{print $5}' |  tr ':' ' ')
  KRN_RLS_DT=$(cat ${SYSCTL_TMP} | grep kern.version | head -n1 | awk '{$1=$2=$3=$4=$5=""; print $0}')
  KRN_EXT_INFO=$(cat ${SYSCTL_TMP} | grep -A2 kern.version | head -n2 | tail -n1)

  FUN_TXT INFO "OS Name: ${OS_INFO} \n Kernel Name: ${KRN_INFO} \n Kerner Releas Date: ${KRN_RLS_DT} \n Kenrel Extra Info: ${KRN_EXT_INFO} \n" 
}


FUN_SYS_TIME () {

  ${PS_APP} aux | grep ntp | grep -v grep 1>&2 > /dev/null
  if [ $? -gt 0 ]; then
    FUN_TXT WARN "NTP is not running on this server !!!!"
    else
    FUN_TXT INFO "NTP is running on this server"
  fi

  SRV_CURR_DATE=$(${DATE_APP})
  FUN_TXT INFO "Current Server Date is: ${SRV_CURR_DATE} "

}


FUN_HW_INFO () {

  CPU_MODEL=$(${SYSCTL_APP} -n hw.model)
  CPU_ARCH=$(${SYSCTL_APP} -n hw.machine_arch)
  CPU_CORE_NUM=$(${SYSCTL_APP} -n hw.ncpu)
  VIRT_TP=$(${SYSCTL_APP} -n kern.vm_guest)

  FUN_TXT INFO "CPU Modek: ${CPU_MODEL} \n CPU Architecture:: ${CPU_ARCH} \n CPU Core Numbers: ${CPU_CORE_NUM} \n Virtualization: ${VIRT_TP} \n" 

}
##### Checking Part .... #######################################################


FUN_SYS_UPTIME ${UPTIME}
FUN_SYS_TTY

FUN_KRN_NAME
#FUN_KRN_ACT_MUD ## What module is Enable on This server

FUN_SYS_TIME ## Diff realtime with Server Time and check Server TimeZone

FUN_HW_INFO


# Temp Files Cleaning ...
rm -rf ${SYSCTL_TMP}




#################################################################################


