#!/bin/bash

# Vars
nodes=("rundeck-1.somedomain.com" "rundeck-2.somedomain.com")
EXECUTIONLOGS=/var/lib/rundeck/logs/rundeck
VARLOGS=/var/log/rundeck
USERFILESDIR=/etc/rundeck/
ACLFILES=*.aclpolicy
REALMSFILE=realm.properties
PROJECTSDIR=/var/lib/rundeck/projects/
DATETIME="date +%m_%d--%H:%M"

# Ensure rsync doesn't hit another rsync
if [ -e /home/rundeck/rsync.lock ]
then
  printf "`$DATETIME` => Rsync job currently running.. Retrying for 15 seconds\n" >> /var/log/rundeck/rsync.log
  i=0
  while [ $i -le 3 ]
  do
      if [ -e /home/rundeck/rsync.lock ]
        then
            sleep 5
            ((i++))
        else
          break
      fi
  done
  printf "`$DATETIME` => Rsync job currently running. Tried 3 times, Exiting\n" >> /var/log/rundeck/rsync.log
  exit
fi

# Begin the actual job
touch /home/rundeck/rsync.lock
printf "`$DATETIME` => Rsync job starting\n" >> /var/log/rundeck/rsync.log

for n in ${nodes[@]}; do
  ssh $n touch /home/rundeck/rsync.lock
  rsync -au $EXECUTIONLOGS/* $n:$EXECUTIONLOGS
  rsync -au $VARLOGS/rundeck.*.log $n:$VARLOGS
  rsync -au $USERFILESDIR/$ACLFILES $USERFILESDIR/$REALMSFILE  $n:$USERFILESDIR
  rsync -au $PROJECTSDIR  $n:$PROJECTSDIR
  ssh $n rm /home/rundeck/rsync.lock
done

rm /home/rundeck/rsync.lock
printf "`$DATETIME` => Rsync job done\n" >> /var/log/rundeck/rsync.log

