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




##### Function Definitions Part .... ###########################################




##### Checking Part .... #######################################################


#FUN_PSQL_OPT ## Checking PSQL Options
#FUN_ZFS_OPT  ## Checkig ZFS Options
#FUN_SCRP_CHK ## Checking Scripts


############################################
Global setting in rc.confg:			
	sendmail_enable="NONE"		
	syslogd_flags="-C -ss"		
			
	postgresql_data="/data/postgres/data96"		
	postgresql_enable="YES"		
			
	harvest_mask="351"		
	zfs_enable="YES"		
	rsyncd_enable="YES"		
	snmpd_enable="YES"		
			
Tuning ZFS:			
	zfs create data/ipdr		
	zfs create data/radius		
	zfs create data/postgres		
	zfs set compression=lz4 data		
	zfs set checksum=fletcher4 data		
	zfs set atime=off data		
	zfs set compression=off data		
	zfs set compression=lz4 data/postgres		
	zfs set recordsize=8k data/postgres		
	zfs set atime=off data/postgres		
	zfs set logbias=throughput data/postgres		
			
Tuning and config postgres			
	change listen_addresses to specific NIC addrs		
	# CUSTOMIZED OPTIONS		
	# Add settings for extensions here		
	#Memory Configuration		
	shared_buffers = 8GB		
	effective_cache_size = 24GB		
	work_mem = 164MB		
	maintenance_work_mem = 2GB		
	# Checkpoint Related Configuration		
	min_wal_size = 512MB		
	max_wal_size = 2GB		
	checkpoint_completion_target = 0.9		
	wal_buffers = 16MB		
	# Network Related Configuration		
	max_connections = 100		
	unix_socket_directories = '/tmp'		
	fsync = off		
	synchronous_commit = off		
	full_page_writes = off		
	effective_io_concurrency=4		
	autovacuum=off		
			
			
			
			
Scripts:			
	/opt/ipdr/bin/import-udr-all.sh	*/6	/opt/ipdr/bin/import-udr.sh
	/opt/ipdr/bin/import-ipdr-all.sh	*/8	/opt/ipdr/bin/import-ipdr.sh
	/opt/ipdr/bin/postprocess-udr.sh	1:01 AM	
	/opt/ipdr/bin/createindex.sh	3:01 AM	

Managment:	grep for error , warning or sth else		
	checking login log for not trusted users		
	checking network Unconventional traffic		
	who login from consol		
Incoming NIC			
	active and incoming data		
	Error Check - netstat -in		
			

LOG:	grep for error , warning or sth else		
	/var/log/auth.log		
	/var/log/messages		
	/var/run/dmesg.boot		
			
			
uptime			
			
file check 	/data/radius or diameter and /data/ipdr		
file life max 15min			
			
Disk size			
checking  table and index	for last day and currnet day (size and validation data)		
			
PSQL			
	Dont have any old query		
	check psql options and tunning options		
			
script checks and check their log files:			
	/opt/ipdr/bin/import-udr-all.sh	*/6	/opt/ipdr/bin/import-udr.sh
	/opt/ipdr/bin/import-ipdr-all.sh	*/8	/opt/ipdr/bin/import-ipdr.sh
	/opt/ipdr/bin/postprocess-udr.sh	1:01 AM	
	/opt/ipdr/bin/createindex.sh	3:01 AM	
			
			
ZFS:			
	Checking options and tunning element		
