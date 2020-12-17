#!/bin/bash

if [ -e /home/rundeck/rsync.lock ]
then
  echo "Rsync job already running...exiting"
  exit
fi
touch /home/rundeck/rsync.lock

EXECUTIONLOGS=/var/lib/rundeck/logs/rundeck
VARLOGS=/var/log/rundeck
USERFILESDIR=/etc/rundeck/
ACLFILES=*.aclpolicy
REALMSFILE=realm.properties
PROJECTSDIR=/var/lib/rundeck/projects/

cd ~ && git clone https://gitlab.com/username/rundeck-nodes.git
if [[ -d ~/rundeck-nodes ]]
then
  git pull
fi

readarray -t nodes < ~/rundeck-nodes/nodelist
#rm -rf ~/rundeck-nodes # If this is run, in cases when git is offline, we will not be able to get a nodes 
#list. So I recommend that we not wipe the file, even though it is not "clean".

# Even if we don't remove the array element containing our own hostname, 
# rsync will fail when trying to copy to itself. ("no ssh key" error)
for n in ${nodes[@]}; do
  rsync -au $EXECUTIONLOGS/* $n:$EXECUTIONLOGS
  rsync -au $VARLOGS/rundeck.*.log $n:$VARLOGS
  rsync -au $USERFILESDIR/$ACLFILES $USERFILESDIR/$REALMSFILE  $n:$USERFILESDIR
  rsync -au $PROJECTSDIR  $n:$PROJECTSDIR
done

rm /home/rundeck/rsync.lock

