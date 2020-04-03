#!/bin/sh

start=`date +%s`
OCC="/var/www/html/occ"

if [ -z "${RESTIC_REPOSITORY}" ]; then
  echo Restic repo is undifined. Skipping backup.
  exit
fi

echo Starting Backup at $(date +"%Y-%m-%d %H:%M:%S")

php $OCC maintenance:mode --on

mysqldump --single-transaction -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > /var/www/html/data/sqlbackup.bak
echo MySQL database dumped

restic backup --verbose --exclude="appdata_*" --exclude="*\.log*" /var/www/html/data /var/www/html/config

if [ -n "${RESTIC_FORGET_ARGS}" ]; then
  echo Forget about old snapshots based on RESTIC_FORGET_ARGS = ${RESTIC_FORGET_ARGS}
  restic forget ${RESTIC_FORGET_ARGS}
fi

php $OCC maintenance:mode --off

end=`date +%s`
echo Finished backup at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds
echo ""
