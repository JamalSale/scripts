#!/bin/bash

BACKUP_DIR=$BACKUP_HOME/$(date +%F)
BACKUP_LABEL=`hostname`_`date`
if [ -f $BACKUP_LOCK ];
then
   echo "===ERROR: Lock file $BACKUP_LOCK already exists, backup in progress."; exit 1
else
touch $BACKUP_LOCK
echo "===INFO: Start backup at `date`"
pg_basebackup -l "$BACKUP_LABEL" -v -x -P -Ft -z -D $BACKUP_DIR && \

#Delete old backup
find $BACKUP_HOME/[0-9]* -maxdepth 0 -type d -mmin +$DAYS_KEEP -exec rm -rf {} \; 

[ -d "$BACKUP_HOME/current" ] || mkdir -p "$BACKUP_HOME/current"; cd $BACKUP_HOME
tar -cf current/current_backup.tar $(date +%F)

#Clean logs
find $TRACE_DIR/*.log -type f -mmin +$TRACE_KEEP_MIN -exec rm -f {} \;
#Delete old arch logs
find $ARCH_DIR/* -maxdepth 0 -type f -mmin +$DAYS_KEEP -exec rm -f {} \; 
#Delete WAL log, keeping last $ARCH_WAL_KEEP count
((DEL_COUNT=$ARCH_WAL_COUNT-$ARCH_WAL_KEEP))
if (( "$DEL_COUNT" > "0" )); then
  find $ARCH_DIR/* -type f |xargs ls -lt|tail -n$DEL_COUNT |awk '{print $9}' | xargs rm -f
fi

rm $BACKUP_LOCK
fi
