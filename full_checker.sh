
#!/bin/sh

#set -x
set -u

PWD=$(pwd)

PROF_CGN_FL="(sys)"             ## Example: "(sys|cpu|ram|nic|cgn)"
PROF_LOGGER_FL="(sys|disk)"        ## Example: "(sys|cpu|ram|nic|disk|logger)"
PROF_STORAGE_FL="(sys|disk)"       ## Example: "(cpu|ram|nic|disk|storage)"

SCRT_CGN=$(ls ${PWD}/fun/ | grep -Ei "${PROF_CGN_FL}" )
SCRT_LOGGER=$(ls ${PWD}/fun/ | grep -Ei "${PROF_LOGGER_FL}" )
SCRT_STORAGE=$(ls ${PWD}/fun/ | grep -Ei "${PROF_STORAGE_FL}" )


FUN_HELP () {
  echo "Enter \"1\" for Help.  (This Message)"
  echo "Enter \"2\" for List of Added Servers."
  echo "Enter \"3\" for List of All Avalable Scripts."
  echo "Enter \"4\" for List of the Avalable Scripts Base on their Profile."
  echo "Enter \"5\" for Run Scripts Base on their Profile."
  echo "Enter \"6\" for Install all Scripts that you need for check. (Not Actived)"
  echo "Enter \"7\" for Backup all Scripts And Config files. (Not Actived)"

}


FUN_SRV_LST () {
  echo "Current Servers that we want to check:"
  if [ -e ${PWD}/srv-list ]; then
    cat ${PWD}/srv-list
  else
    touch ${PWD}/srv-list
    echo -e "[PROFILE]\t[SEVERs]" > ${PWD}/srv-list
    echo -e "########################" >> ${PWD}/srv-list
    echo -e "" >> ${PWD}/srv-list

  fi
    echo "if your are want to add more server, press \"y\" , if dont press \"n\" :"
  read ANS
  case $ANS in
    "y")
      while [ "${ANS}" = "y" ] ; do
        echo "CGN Profile :"
        echo "Pleas Enter ServerName or IP that you want to add to CGN profile:"
        echo "U cat input multiple Servers , seperated is \",\":"
        read SRVTMP
        echo ${SRVTMP} | tr ',' '\n' | while read line ; do echo -e "cgn\t${line}" >> ${PWD}/srv-list ; done

        echo "LOGGER Profile :"
        echo "Pleas Enter ServerName or IP that you want to add to LOGGER profile:"
        echo "U cat input multiple Servers , seperated is \",\":"
        read SRVTMP
        echo ${SRVTMP} | tr ',' '\n' | while read line ; do echo -e "logger\t${line}" >> ${PWD}/srv-list ; done

        echo "STORAGE Profile :"
        echo "Pleas Enter ServerName or IP that you want to add to STORAGE profile:"
        echo "U cat input multiple Servers , seperated is \",\":"
        read SRVTMP
        echo ${SRVTMP} | tr ',' '\n' | while read line ; do echo -e "storage\t${line}" >> ${PWD}/srv-list ; done


        echo "Do you want to add another server? (y/n) "
        read ANS
      done
      echo "New Server list: "
      cat ${PWD}/srv-list
      ;;
    "n")
      FUN_HELP 1
      #echo "Are You want to check base on this New Profile list? "
      # yes or no
      # exit or RUN FUN_RUN_CHK
      # break
      ;;
    *)
      echo "Please Enter \"y\" or \"n\" "
      break
      ;;
  esac

}


FUN_SCRT_LST () {
  SCRT_AVL=$(ls ${PWD}/fun/)
  echo -e "List of the All Avalable Scripts:\n"
  echo -e "${SCRT_AVL}\n"

}


FUN_PROF_LST () {
  SCRT_AVL=$(ls ${PWD}/fun/)
  echo -e "::\n"
  echo -e "List of the All Avalable Scripts Base on their Profile:\n"
  echo -e "::\n"
  echo -e "CGN:\n"
  echo -e "${SCRT_CGN}\n"
  echo -e "::\n"
  echo -e "LOGGER:\n"
  echo -e "${SCRT_LOGGER}\n"
  echo -e "::\n"
  echo -e "STORAGE:\n"
  echo -e "${SCRT_STORAGE}\n"

#FIXME: Add custome profle
#FIXME: change currnet profle

}


FUN_RUN_CHK () {
  echo
  if [ -e ${PWD}/srv-list ]; then
   echo -e "Runing Checking Scripts per Profile ....\n"
   echo -e "::\n"
   echo -e "CGN:\n"
   echo -e ${SCRT_CGN} | tr ' ' '\n' | while read input1
     do
       cat ${PWD}/srv-list | grep "^cgn" | awk '{print $2}' | while read input2
         do
           ssh ${input2} "sh" < ${PWD}/fun/${input1}
         done
     done


     echo -e "::\n"
     echo -e "LOGGER:\n"
     echo -e ${SCRT_LOGGER} | tr ' ' '\n' | while read input1
       do
         cat ${PWD}/srv-list | grep "^logger" | awk '{print $2}' | while read input2
           do
             ssh ${input2} "sh" < ${PWD}/fun/${input1}
          done
       done


   echo -e "::\n"
   echo -e "STORAGE:\n"
   echo -e ${SCRT_STORAGE} | tr ' ' '\n' | while read input1
     do
       cat ${PWD}/srv-list | grep "^storage" | awk '{print $2}' | while read input2
         do
           ssh ${input2} "sh" < ${PWD}/fun/${input1}
         done
     done
  else
    echo "We Dont have any srv-list file, first you must create it: \n "
    FUN_SRV_LST
  fi


}



FUN_INT_CHK () {

  echo -e "Comming soon ..\n"

#FIXME: setup completely all SCRIPTS

}


if [ $# -lt 1 ]; then
   echo "Please Run:  \"$0 1\" "
else
  case $1 in
    1)
      FUN_HELP
      ;;
    2)
      FUN_SRV_LST
      ;;
    3)
      FUN_SCRT_LST
      ;;
    4)
      FUN_PROF_LST
      ;;
    5)
      FUN_RUN_CHK
      ;;
    6)
      FUN_INT_CHK
      ;;
    *)
      FUN_HELP
      ;;
  esac
fi



## Add script that you want to RUN:
SCRIPTS="cpu_checker hdd_checker nic_checker"

#/home/amirreza/ARH/MyData/myGIT/Server-Health-Checker/fun/cpu_checker.sh
#/home/amirreza/ARH/MyData/myGIT/Server-Health-Checker/fun/hdd_checker.sh
#/home/amirreza/ARH/MyData/myGIT/Server-Health-Checker/fun/nic_checker.sh

#Syntax: CUSTOMER.ServerName --> exp: rightel.cgn2



################################################################################
################################################################################
###################################  HDD  ######################################
################################################################################
################################################################################




################################################################################
################################################################################
###################################  NIC  ######################################
################################################################################
################################################################################




################################################################################
################################################################################
###################################  CPU  ######################################
################################################################################
################################################################################








################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

## work with TMUX


#END

: <<'GOAL'




Script Service base bashe :
masalan to scrpit logger:
FUN_NIC_ERR ${LOG_NIC}


script vaghti run mishe, list server haro bar asase service hashon begire.
bad be ezaye har service v server ha FUN hayee ke mikhaym ro run kone
\

### MUST be Added in future ...


##################################################### Service Checking
#CGNAT # Fragmented	- State Insert Failure	- State Mismatch ....
#LOGGER - Ruunig logger , data validation ,
#DATABASE , no error , checkings insert to table , index checking , Query gir nakarde bashe ....
#Search    # Merge IPDR vs UDR .. no error
# Checking Scripte
# Security checking ;  OPEN_PORT ....

GOAL
