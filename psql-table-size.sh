#!/bin/sh


DATE=$(date "+%Y%m%d")
PGUSER="postgres" ### or pgsql
PSQL="/usr/local/bin/psql"
PGDBname="ipdr"
SUDO="/usr/local/bin/sudo"

case $1 in
  "ipdr")
    TABLE="ipdr${DATE}"
    ;;
  "udr")
    TABLE="udr${DATE}"
    ;;
  *)
    echo "Please input \"ipdr\" or \"udr\" "
    exit 1
    ;;
esac

COUNT=$(${SUDO} -u ${PGUSER} ${PSQL} ${PGDBname} -c "select state from pg_stat_activity where state='active';" | grep -i "row" | tr -dc '0-9')
if [ ${COUNT} -gt 2 ]; then
  echo "Please try some minutes later..."
else
  ${SUDO} -u ${PGUSER} ${PSQL} -A -t ${PGDBname} -c "SELECT  pg_table_size('${TABLE}')" > /tmp/tablesize
fi
