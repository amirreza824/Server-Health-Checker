#!/bin/sh

set x

APP_mfiutil="/usr/sbin/mfiutil"
APP_geom="/usr/sbin/geom"

if   [ -x ${APP_mfiutil} ]
  then
      hdd_info=`${APP_mfiutil} show drives`
        if [ $? -ne 0 ]
          then
            exit 1
        fi
elif [ -x ${APP_geom} ]
  then
      hdd_info=`${APP_geom} disk list`
else
      echo "No HDD Information Available on this Server "
fi



case hdd_app in

# Space as Delomitter


hdd_part=$(expr `df -h | grep -E -v '(devfs|fdescfs)' | wc -l` - 1 )
hdd_titel="Filesystem Size Used  Avail Capacity  Mounted"
hdd_partitions=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $1}' | tail -n${hdd_part} | tr '\n' ' ')
hdd_Size=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $2}' | tail -n${hdd_part} | tr '\n' ' ')
hdd_Used=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $3}' | tail -n${hdd_part} | tr '\n' ' ')
hdd_Avail=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $4}' | tail -n${hdd_part} | tr '\n' ' ')
hdd_Capacity=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $5}' | tail -n${hdd_part} | tr '\n' ' ')
hdd_Mounted_on=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $6}' | tail -n${hdd_part} | tr '\n' ' ')

hdd_size_checher () {
  for i in ${hdd_Capacity}
    do
      if [ `echo $i| cut -f1 -d "%"` -ge 80 ]
        then
          echo WARNING
        fi
      done
}


hdd_size_checher
