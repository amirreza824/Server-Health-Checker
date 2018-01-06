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
###################################  NIC  ######################################
################################################################################
################################################################################

EXCLUDE_IF="pflog0|lo0|pfsync0|enc0" # exp: EXCLUDE_IF="pflog0|lo0|pfsync0"
IF_LIST=$(ifconfig -l | sed -E s/$EXCLUDE_IF//g )
NETSTAT="/usr/bin/netstat"
IFCONFIG="/sbin/ifconfig"
NIC_TMP_FILE=$(mktemp -t NIC)
NIC_TMP_FILE_RATE=$(mktemp -t NIC)
${NETSTAT} -ibn > $NIC_TMP_FILE
sleep 1
${NETSTAT} -ibn > $NIC_TMP_FILE_RATE # Use for Link Rate Calculation
IF_MOD_FLTR="UP|BROADCAST|SIMPLEX|MULTICAST" # Interfaces Mode Filter for checking

##### Function Definitions Part .... ###########################################

FUN_NIC_MODE () {
  echo $IF_LIST | tr ' ' '\n' | while read line
    do
      IF_STAT=$(${IFCONFIG} ${line} | grep -i status | awk -F ": " '{print $2}')
      IF_MODE=$(${IFCONFIG} ${line} | grep -i flags | tr -dc "A-Z," | sed -E "s/${IF_MOD_FLTR}|,/ /g")
      IF_CARP=$(${IFCONFIG} ${line} | grep -i carp | awk '{print $2}')
      IF_MTU=$(${IFCONFIG} ${line} | grep -i flags | cut -d " " -f 6)
#FIXME: Less run ifconfig !!!!
      case ${IF_STAT} in
        "active")
          FUN_TXT INFO "Link \"${line}\" is UP."
          FUN_TXT INFO "Active Mode for link \"${line}\" : \n ${IF_MODE}"
          if [ -n "${IF_CARP}" ]; then
            if [ "${IF_CARP}" = "INIT" ]; then
              FUN_TXT ERR "CARP is NOT Active on \"${line}\" \n CARP mode --> ${IF_CARP}"
            else
              FUN_TXT INFO "CARP is Active on \"${line}\" \n CARP mode --> ${IF_CARP}"
            fi
          fi
          FUN_TXT INFO "MTU -->  \"${IF_MTU}\" "
          ;;
        "no carrier")
          FUN_TXT ERR "Link \"${line}\" is DOWN"
          ;;
        *)
          FUN_TXT WARN "Link \"${line}\" did not Detected !!!"
#FIXME: Add more states , but I didnt find any type...
          ;;
      esac
    done

}

FUN_NIC_SPD () {
  echo $IF_LIST | tr ' ' '\n' | while read line
    do
      MED_TYP=$(${IFCONFIG} ${line} | grep -i media | grep -v manual)
      if [ -n "${MED_TYP}" ]; then
        MED_SPD=$(echo ${MED_TYP} | grep -o -E '[0-9]+[Gbase]+')
        if [ -n "${MED_SPD}" ]; then
            if [ "${MED_SPD}" = "10Gbase" ] || [ "${MED_SPD}" = "1000base" ] || [ "${MED_SPD}" = "40Gbase" ]; then
                FUN_TXT INFO "\"${line}\" ok --> \"${MED_SPD}\""
            else
                FUN_TXT ERR "We have a low speed link (\"${MED_SPD}\") on \"${line}\""
            fi
        fi
       fi
    done
}


FUN_NIC_ERR () {
  echo $IF_LIST | tr ' ' '\n' | while read line
    do
      INP_ERR=$(cat $NIC_TMP_FILE | grep -i $line | head -n1 | awk '{print $6}')
        if [ $INP_ERR -gt 0 ] ; then
          FUN_TXT ERR "We have Interface Input Error on \"$line\" with Error Value = \"$INP_ERR\""
        fi
        OUT_ERR=$(cat $NIC_TMP_FILE | grep -i $line | head -n1 | awk '{print $10}')
        if [ $OUT_ERR -gt 0 ] ; then
          FUN_TXT ERR "We have Interface Input Error on \"$line\" with Error Value = \"$OUT_ERR\""
        fi
    done
}

FUN_NIC_RATE () {
  echo $IF_LIST | tr ' ' '\n' | while read line
    do
      # Input Bit/Sec Calculation
      #NIC_INP_bps=$(echo "(" $(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $8}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $8}') ")" / 8 | ${CALC} )
      NIC_INP_bps=$(echo  $((($(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $8}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $8}')) / 8 )))
      echo INPUT: ${NIC_INP_bps} Bit/Sec ${line}

      # Output Bit/Sec Calculation
      #NIC_OUT_bps=$(echo "(" $(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $11}') - $(cat ${NIC_TMP_FILE} | grep -i $line | head -n1 | awk '{print $11}') ")" / 8 | ${CALC} )
      NIC_OUT_bps=$(echo $((($(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $11}') - $(cat ${NIC_TMP_FILE} | grep -i $line | head -n1 | awk '{print $11}')) / 8 )))
      echo OUTPUT: ${NIC_OUT_bps} Bit/Sec ${line}

      echo
      echo

      # Input Packet/Sec Calculation
      #NIC_INP_pps=$(echo "(" $(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $5}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $5}') ")" / 8 | ${CALC} )
      NIC_INP_pps=$(echo $((($(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $5}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $5}')) / 8 )))
      echo OUTPUT: ${NIC_INP_pps} Packet/Sec ${line}

      # Output Packet/Sec Calculation
      #NIC_OUT_pps=$(echo "(" $(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $9}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $9}') ")" / 8 | ${CALC} )
      NIC_OUT_pps=$(echo $((($(cat ${NIC_TMP_FILE_RATE} | grep -i ${line} | head -n1 | awk '{print $9}') - $(cat ${NIC_TMP_FILE} | grep -i ${line} | head -n1 | awk '{print $9}')) / 8 )))
      echo OUTPUT: ${NIC_OUT_pps} Packet/Sec ${line}

      echo
      echo

      # Input Average packet size calculation
      if [ "${NIC_INP_bps}" = "0" ] || [ "${NIC_INP_pps}" = "0" ]; then
        NIC_INP_APS="0"
        echo "INPUT: ${NIC_INP_APS} packet size ${line}"
      else
        #NIC_INP_APS=$(echo ${NIC_INP_bps} / ${NIC_INP_pps} | ${CALC})
        NIC_INP_APS=$(echo $(( ${NIC_INP_bps} / ${NIC_INP_pps} )))
        echo "INPUT: ${NIC_INP_APS} packet size ${line}"
      fi

      # Output Average packet size calculation\
      if [ "${NIC_OUT_bps}" = "0" ] || [ "${NIC_OUT_pps}" = "0" ]; then
        NIC_OUT_APS="0"
        echo "INPUT: ${NIC_OUT_APS} packet size ${line}"
      else
        #NIC_OUT_APS=$(echo ${NIC_OUT_bps} / ${NIC_OUT_pps} | ${CALC})
        NIC_OUT_APS=$(echo $(( ${NIC_OUT_bps} / ${NIC_OUT_pps} )))
        echo "INPUT: ${NIC_OUT_APS} packet size ${line}"
      fi

      echo
      echo
      echo
    done
#FIXME: Add Max v Min threshhold per customer
#FIXME: the value is returned by this script is diffrent from Grafana !!!!!!!!!!
#FIXME: every Link has a two line in netstat Output, I have to chose one of them !!!!!!!!!!!!!!!
#FIXME: User can change Bit/s , KBit/s , MBit/s , Kbyte/s , ....
#FIXME: This function must smarter!!!!

}

##### Checking Part .... #######################################################


FUN_TXT INFO "We are Checking \"$IF_LIST\" Interfaces ..."

#FUN_NIC_MODE # Acitve/no carrier ,  noarp , monitor , ip , ....
FUN_NIC_SPD # Media Link Speed Check
#FUN_NIC_ERR # Checking for Input / Output physical Error

#FUN_TXT INFO "Link Rates:"
#FUN_NIC_RATE ## RX , TX --- bps and pps --- Average packet size


#FUN_NIC_QUE # count , value , ....


rm -rf $NIC_TMP_FILE # Removing Temp file
rm -rf $NIC_TMP_FILE_RATE # Removing Temp file




: <<'HELP'
if [ "$INTERFACE" = "aggregated" ]; then
	/usr/bin/netstat -i -b -n | grep -v '^lo' | awk '
BEGIN { rsum = 0; osum = 0; }
/<Link#[0-9]*>/ {
	if (NF == 10) {
		rsum += $6; osum += $9;
	} else if (NF == 11) {
		if ($4 ~ /:/) {
			rsum += $7; osum += $10;
		} else {
			rsum += $7; osum += $10;
		}
	} else { # NF == 12
		rsum += $8; osum += $11;
	}
}
END {
	printf "rbytes.value %i\n", rsum;
	printf "obytes.value %i\n", osum;
}'

else
	/usr/bin/netstat -i -b -n -I $INTERFACE | awk '
/<Link#[0-9]*>/ {
	if (NF == 10) {
		print "rbytes.value", $6;
		print "obytes.value", $9;
	} else if (NF == 11) {
		if ($4 ~ /:/) {
			print "rbytes.value", $7;
			print "obytes.value", $10;
		} else {
			print "rbytes.value", $7;
			print "obytes.value", $10;
		}
	} else { # NF == 12
		print "rbytes.value", $8;
		print "obytes.value", $11;
	}
}'
fi


HELP
