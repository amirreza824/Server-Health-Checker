#!/bin/sh

set x

APP_mfiutil="/usr/sbin/mfiutil"
APP_geom="/sbin/geom"

echo <<T

if   [ -x ${APP_mfiutil} ]
  then
    ${APP_mfiutil} show drives
        if [ $? -ne 0 ]
          then
            echo
            echo "Please install and Config mfiutil"
            echo
        fi
fi

if [ -x ${APP_geom} ]
  then
    ${APP_geom} disk list
    echo $hdd_info
else
    echo "No HDD Information Available on this Server "
fi
T


# Space as Delomitter

#hdd_part=$(expr `df -h | grep -E -v '(devfs|fdescfs)' | wc -l` - 1 )
#hdd_titel="Filesystem Size Used  Avail Capacity  Mounted"
#hdd_partitions=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $1}' | tail -n${hdd_part} | tr '\n' ' ')
#hdd_Size=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $2}' | tail -n${hdd_part} | tr '\n' ' ')
#hdd_Used=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $3}' | tail -n${hdd_part} | tr '\n' ' ')
#hdd_Avail=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $4}' | tail -n${hdd_part} | tr '\n' ' ')
#hdd_Capacity=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $5}' | tail -n${hdd_part} | tr '\n' ' ')
#hdd_Mounted_on=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $6}' | tail -n${hdd_part} | tr '\n' ' ')


hdd_part=$(expr `df -h | grep -E -v '(devfs|fdescfs)' | wc -l` - 1 )

hdd_titel[0]="Filesystem"
hdd_titel[1]="Size"
hdd_titel[2]="Used"
hdd_titel[3]="Avail"
hdd_titel[4]="Capacity"
hdd_titel[5]="Mounted"

hdd_partitions=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $1}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_partitions}
  do
    hdd_partitions[${y}]=${i}
    y=$((y + 1))
  done

hdd_Size=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $2}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_Size}
  do
    hdd_Size[${y}]=${i}
    y=$((y + 1))
  done

hdd_Used=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $3}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_Used}
  do
    hdd_Used[${y}]=${i}
    y=$((y + 1))
  done

hdd_Avail=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $4}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_Avail}
  do
    hdd_Avail[${y}]=${i}
    y=$((y + 1))
  done

hdd_Capacity=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $5}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_Capacity}
  do
    hdd_Capacity[${y}]=${i}
    y=$((y + 1))
  done

hdd_Mounted_on=$(df -h | grep -E -v '(devfs|fdescfs)' | awk '{print $6}' | tail -n${hdd_part} | tr '\n' ' ')
y=0
for i in ${hdd_Mounted_on}
  do
    hdd_Mounted_on[${y}]=${i}
    y=$((y + 1))
  done

echo amir
hdd_size_checher () {
  y=0
  #for i in $(seq 1 ${hdd_part})
  for i in $(seq 0 6)
    do
      echo ${hdd_Capacity[${i}]} AND  ${hdd_Mounted_on[${i}]}
      hdd_temp_var=`echo ${hdd_Capacity[${i}]} | cut -f1 -d "%"`
      if [ `echo ${hdd_temp_var}` -ge 60 ]
        then
          echo "WARNING space for ${hdd_Mounted_on[${y}]} "
        fi
      y=$((y + 1))
    done
}


hdd_size_checher


echo ${hdd_titel[4]}

echo ${hdd_Mounted_on[6]}
echo ${hdd_Capacity[6]}
