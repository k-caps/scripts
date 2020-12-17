#!/bin/bash
REPLOG=/var/log/repmgr/autoclone.log
if [[ -e $PGDATA/repmgr_autoclone.lock ]]
then
	echo `date +%d/%m" "%H:%M`" =>  FOLLOW NEW PRIMARY: Unable to execute, another instance of this script was running already."  >> $REPLOG && echo "" >> $REPLOG
	exit 1
else

	set -e

	PG_VERSION=10
	REPMGR_CONF_FILE=/etc/repmgr/$PG_VERSION/repmgr.conf
	PGDATA=/var/lib/pgsql/$PG_VERSION/data/
	touch $PGDATA/repmgr_auto_fo.lock
	export PGPASSWORD=Yeswecan2015

	# Check what node is currently acting as primary
	NUMBER_OF_PRIMARIES=$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show| grep primary | egrep -v '^  - ' | awk -F '|' '{ print $2}'  | wc -l)
	if [[ $NUMBER_OF_PRIMARIES > 1 ]]
	then
		CURRENT_PRIMARY=$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show| grep primary | grep -v 'running as standby' | awk  -F '|' '{ print $2}' | xargs)
	else
		CURRENT_PRIMARY=$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show | grep primary | grep '* running ' | awk -F '|' '{ print $2}' | xargs)
		if [[ -z $CURRENT_PRIMARY ]]
		then 
			CURRENT_PRIMARY=$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show | grep primary | grep '! running as primary ' | awk -F '|' '{ print $2}' | xargs)
		fi
	fi
	unset ip_mapping
	declare -A ip_mapping

	ip_mapping=( \
	["N1"]="$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show |awk -F '|' 'NR>2{print $2$9}' | awk '$1=="N1"{print $2}' | awk -F'=' '{print$2}')" \
	["N2"]="$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show |awk -F '|' 'NR>2{print $2$9}' | awk '$1=="N2"{print $2}' | awk -F'=' '{print$2}')" \
	["N3"]="$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf cluster show |awk -F '|' 'NR>2{print $2$9}' | awk '$1=="N3"{print $2}' | awk -F'=' '{print$2}')" \
	)

	THISNODE=$(cat $REPMGR_CONF_FILE | grep node_name  | awk -F "'" '{ print $2}')
	THISNODE_UPSTREAM=$(/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf  cluster show| grep $THISNODE | awk -F '|' '{ print $5}')
	CURRENT_PRIMARY_IP=$(echo ${ip_mapping[`echo $CURRENT_PRIMARY`]})

	if [[ $(echo $CURRENT_PRIMARY |xargs) == $(echo $THISNODE_UPSTREAM | xargs) ]]
	then
		echo `date +%d/%m" "%H:%M`" =>  FOLLOW NEW PRIMARY: No action needed, this node ($THISNODE) was following the primary already"  >> $REPLOG && echo "" >> $REPLOG
		exit 0
	else 
		rm -rf $PGDATA/*
		mkdir -p $PGDATA
		/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf standby clone --force-rewind --force -h ${ip_mapping[`echo $CURRENT_PRIMARY`]} -U repuser -d postgres
		sudo systemctl restart postgresql-$PG_VERSION 
		/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf standby register --force
		RC=$?
		if [[ $RC == 0 ]]
		then		
			echo `date +%d/%m" "%H:%M`" =>  FOLLOW NEW PRIMARY: This node ($THISNODE) was changed to follow the new master, $CURRENT_PRIMARY"  >> $REPLOG && echo "" >> $REPLOG
		else 
			echo `date +%d/%m" "%H:%M`" =>  FOLLOW NEW PRIMARY: ERROR!!! We were unable to perform an automatic failover." >> $REPLOG && echo "" >> $REPLOG
			echo Please run \`/usr/pgsql-$PG_VERSION/bin/repmgr -f /etc/repmgr/$PG_VERSION/repmgr.cluster show\` for more information.  >> $REPLOG && echo "" >> $REPLOG
		fi
	fi

	rm $PGDATA/repmgr_autoclone.lock
fi
