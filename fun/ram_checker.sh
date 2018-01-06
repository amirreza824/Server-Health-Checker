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
###################################  RAM  ######################################
################################################################################
################################################################################

SYSCTL_APP='/sbin/sysctl'
TOP_APP='/usr/bin/top'
VMST_APP='/usr/bin/vmstat'
SWP_INFO='/usr/sbin/swapinfo'

MEMO_FREE_THR='80' ## Free Memory Threshold - percentage
SWAP_FREE_THR='80' ## Free Memory Threshold - percentage

RAM_SYSCTL_TMP=$(mktemp -t RAM)
${SYSCTL_APP} -a > ${RAM_SYSCTL_TMP}

RAM_TOP_TMP=$(mktemp -t RAM)
${TOP_APP} -d1 > ${RAM_TOP_TMP}

RAM_VMST_TMP=$(mktemp -t RAM)
${VMST_APP} -s > ${RAM_VMST_TMP}

SWP_INFO_TMP=$(mktemp -t SWP)
${SWP_INFO} > ${SWP_INFO_TMP}


##### Function Definitions Part .... ###########################################


FUN_MEMO_INFO () {

  mem_page_size=`cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_page_size" | awk '{print $2}'`
  mem_page_count=`cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_page_count" | awk '{print $2}'`

  mem_phys=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "hw.realmem" | awk '{print $2}'))))
  mem_hw=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "hw.physmem" | awk '{print $2}'))))

  mem_all=$(echo $((${mem_page_count} * ${mem_page_size})))

  mem_wire=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_wire_count" | awk '{print $2}') * ${mem_page_size})))
  mem_active=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_active_count" | awk '{print $2}') * ${mem_page_size})))
  mem_inactive=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_inactive_count" | awk '{print $2}') * ${mem_page_size})))
  mem_cache=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_cache_count" | awk '{print $2}') * ${mem_page_size})))
  mem_free=$(echo $(($(cat $RAM_SYSCTL_TMP | grep "vm.stats.vm.v_free_count" | awk '{print $2}') * ${mem_page_size})))

  #   determine the individual unknown information
  mem_gap_vm=$(echo $((${mem_all} - (${mem_wire} + ${mem_active} + ${mem_inactive} + ${mem_cache} + ${mem_free}))))
  mem_gap_sys=$(echo $((${mem_hw} - ${mem_all})))
  mem_gap_hw=$(echo $((${mem_phys} - ${mem_hw})))

  #   determine logical summary information
  mem_avail=$(echo $((${mem_inactive} + ${mem_cache} + ${mem_free})))
  mem_used=$(echo $((${mem_all} - ${mem_avail})))


  echo "Total real memory installed => \"${mem_phys}\" ( \"$((${mem_phys}/1024/1024)) MB\" ) "
  echo "Total logical memory managed => \"${mem_all}\" ( \"$((${mem_all}/1024/1024)) MB\" )"
  echo
  echo "Logically available memory => \"${mem_avail}\" ( \"$((${mem_avail}/1024/1024)) MB\" )  ( \"$(($((${mem_avail}*100))/${mem_all}))%\" )"
  echo "Logically used memory => \"${mem_used}\" ( \"$((${mem_used}/1024/1024)) MB\" )  ( \"$(($((${mem_used}*100))/${mem_all}))%\" )"
  echo
  echo "Memory gap: Kernel?! => \"${mem_gap_sys}\" ( \"$((${mem_gap_sys}/1024/1024)) MB\" )"
  echo "Memory gap: UNKNOWN - Maby Its Buffer => \"${mem_gap_vm}\" ( \"$((${mem_gap_vm}/1024/1024)) MB\" )"
  echo "Memory gap: Segment Mappings?! => \"${mem_gap_hw}\" ( \"$((${mem_gap_hw}/1024/1024)) MB\" )"
  echo

  echo Details:
  echo Actice: $(($mem_active/1024/1024))
  echo InActice: $(($mem_inactive/1024/1024))
  echo Wired: $(($mem_wire/1024/1024))
  echo Cache: $(($mem_cache/1024/1024))
  echo Free: $(($mem_free/1024/1024))
  echo


#FIXME: Cacl BUFF_size
#FIXME: Fix some Diff value between sysctl and top
#FIXME: Cacl page in / out count


# Only for output compare ...
  cat $RAM_TOP_TMP | egrep -i '(Mem)'
  echo

## Gathering Swap Info ...

  FUN_TXT INFO "Swap Space info ..."
  #SWAP_ALL=$(cat ${RAM_SYSCTL_TMP} | grep "vm.swap_total" | awk '{print $2}')

  #FIXME: Also we can use???:
  #vm.stats.vm.v_swappgsout: 0
  #vm.stats.vm.v_swappgsin: 0
  #vm.stats.vm.v_swapout: 0
  #vm.stats.vm.v_swapin: 0

  #vm.swap_maxpages: 1909664
  #vm.swap_reserved: 296583168
  #vm.swap_total: 2684354560

  echo
  cat ${RAM_TOP_TMP} | egrep -i '(Swap)'

}

FUN_MEMO_CHK () {
  local MEME_AVA_TMP=$(($((${mem_avail}*100))/${mem_all}))
  if [ ${MEME_AVA_TMP} -gt ${MEMO_FREE_THR} ]; then
    FUN_TXT WARN "Memory is almost FULL .... \"${MEME_AVA_TMP}% \" "
  fi



  local SWAP_TOTAL_TMP=$(( $(cat ${SWP_INFO_TMP} | awk '{print $2}' | tail -n1) / 1024))
  local SWAP_AVA_TMP=$(( $(cat ${SWP_INFO_TMP} | awk '{print $4}' | tail -n1) / 1024))

  if [ ${SWAP_AVA_TMP} -lt $((${SWAP_TOTAL_TMP}/3)) ]; then
    FUN_TXT WARN "Swap Space is almost FULL .... \" $((((${SWAP_TOTAL_TMP} - ${SWAP_AVA_TMP})/${SWAP_AVA_TMP})*100)) % \" "
  fi





}


##### Checking Part .... #######################################################

FUN_TXT INFO "SYSTEM MEMORY INFORMATION:"
FUN_MEMO_INFO

FUN_MEMO_CHK

# Temp Files Cleaning ...
rm -rf ${RAM_SYSCTL_TMP}
rm -rf ${RAM_TOP_TMP}
rm -rf ${RAM_VMST_TMP}
rm -rf ${SWP_INFO_TMP}





: <<'HELP'

swapinfo -h

vmstat -s gives some more human-readable or script-parseable information, including listing the page size. Otherwise, it gives output in numbef of pages. With no options, vmstat gives a brief summary.

# vmstat -s
139502112 cpu context switches
 15623506 device interrupts
 12306074 software interrupts
 38657534 traps
205685737 system calls
       17 kernel threads created
    15226  fork() calls
    16739 vfork() calls
        0 rfork() calls
     1637 swap pager pageins
     7507 swap pager pages paged in
     1515 swap pager pageouts
     6872 swap pager pages paged out
     9532 vnode pager pageins
    53300 vnode pager pages paged in
        0 vnode pager pageouts
        0 vnode pager pages paged out
     1981 page daemon wakeups
  7716562 pages examined by the page daemon
    52826 pages reactivated
  2656011 copy-on-write faults
      349 copy-on-write optimized faults
 21044597 zero fill pages zeroed
    12537 zero fill pages prezeroed
     5930 intransit blocking page faults
 26460449 total VM faults taken
    10559 page faults requiring I/O
        0 pages affected by kernel thread creation
  1012031 pages affected by  fork()
   578089 pages affected by vfork()
        0 pages affected by rfork()
  5653063 pages cached
 54588867 pages freed
        0 pages freed by daemon
 11213661 pages freed by exiting processes
     3198 pages active
   124235 pages inactive
     3365 pages in VM cache
   104046 pages wired down
    14259 pages free
     4096 bytes per page
 50259633 total name lookups
          cache hits (57% pos + 1% neg) system 0% per-directory
          deletions 1%, falsehits 0%, toolong 0%

HELP
