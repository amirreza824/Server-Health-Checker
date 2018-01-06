#!/bin/sh

#set -x
set -u



HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")
CALC="/usr/bin/bc"
SYSCTL_APP='/sbin/sysctl'
VMSTAT_APP='/usr/bin/vmstat'
CPU_IDLE_THR='90'  ## CPU IDLE THRESHHOLD
PS_APP='/bin/ps'
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


##### Function Definitions Part .... ###########################################

FUN_CPU_INT () {

  CPU_COUNT=`${SYSCTL_APP} -n hw.ncpu`
  CPU_INTR=$(${VMSTAT_APP} -Pn0 -c2 -w1 | awk 'BEGIN{print "# Core Number , user time , System time , CPU idle_"}{getline;getline;getline}{for(c='$CPU_COUNT'-1;c>=0;c--){print "CPU: "'$CPU_COUNT'-1-c" , "$(NF-c*3-2)" , "$(NF-c*3-1)" , "$(NF-c*3) "_" ;}}')
  COUNT=$(echo "${CPU_COUNT} + 1" | ${CALC})
  echo ${CPU_INTR} | tr '_' '\n' | head -n ${COUNT} | awk '{print $0}{if ($8 < '$CPU_IDLE_THR'){print "CPU Load Warning !!!\n"}}' 
  
}


FUN_CPU_ZMB () {

  CPU_ZAMB=$(${PS_APP} -aux |  grep -w Z | grep -v grep)
  if [ $? -lt 1 ]
  then
    CPU_ZAMB_PID=$(echo $CPU_ZAMB | awk '{for (i=1;i<=NF;i++){if ($i=="root"){print $(i+1)}}}')
    FUN_TXT WARN "There are some ZAMBIE App \n PIDs are:\n ${CPU_ZAMB_PID} " 
  fi

}


##### Checking Part .... #######################################################

FUN_CPU_INT

FUN_CPU_ZMB


FUN_CPU_LOAD 
FUN_CPU_APP_HI ## ps aux | head | sort -nk3 -r | awk '{print }'

#################################################################################




: <<'HELP'
cpu     Breakdown of percentage usage of CPU time.

        us      user time for normal and low priority processes
        sy      system time
        id      cpu idle

procs   Information about the numbers of processes in various states.

        r       in run queue
        b       blocked for resources (i/o, paging, etc.)
        w       runnable or short sleeper (< 20 secs) but swapped

memory  Information about the usage of virtual and real memory.  Virtual
        pages (reported in units of 1024 bytes) are considered active if
        they belong to processes which are running or have run in the
        last 20 seconds.

        avm     active virtual pages
        fre     size of the free list


        page    Information about page faults and paging activity.  These are
                averaged each five seconds, and given in units per second.

                flt     total number of page faults
                re      page reclaims (simulating reference bits)
                pi      pages paged in
                po      pages paged out
                fr      pages freed per second
                sr      pages scanned by clock algorithm, per-second


       faults  Trap/interrupt rate averages per second over last 5 seconds.

                in      device interrupts per interval (including clock interrupts)
                sy      system calls per interval
                cs      cpu context switch rate (switches/interval)

HELP

#HOSTNAME=`hostname`
#LOAD=70.00
#CAT=/bin/cat
#MAILFILE=/tmp/mailviews
#MAILER=/bin/mail
#mailto="EMAILADDRESS"
#CPU_LOAD=`sar -P ALL 1 2 |grep 'Average.*all' |awk -F" " '{print 100.0 -$NF}'`
#if [[ $CPU_LOAD > $LOAD ]];
#then
#PROC=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1`
#echo "Please check your processess on ${HOSTNAME} the value of cpu load is $CPU_LOAD % & $PROC" > $MAILFILE
#$CAT $MAILFILE | $MAILER -s "CPU Load is $CPU_LOAD % on ${HOSTNAME}" $mailto
#fi

#add zombie checker
# ye `ps dax` begir azash bebin chian
#root@xdrc1:~ # top

#last pid: 46194;  load averages:  1.68,  1.95,  2.05                                                                                                                up 301+15:50:45 10:29:25
#66 processes:  1 running, 58 sleeping, 7 zombie


#Use top or ps command:
# top

#OR
# ps aux | awk '{ print $8 " " $2 }' | grep -w Z

#Output:

#Z 4104
#Z 5320
#Z 2945
#How do I kill zombie process?

#You cannot kill zombies, as they are already dead. But if you have too many zombies then kill parent process or restart service.

#You can kill zombie process using PID obtained from any one of the above command. For example kill zombie proces having PID 4104:
# kill -9 4104

#Please note that kill -9 does not guarantee to kill a zombie process
