#!/bin/bash

log=~/dskchk.log
lockfile=~/.dskchk.lock
device=/ #checks this mount point's usage
max_allowed_usage_level=90
pguser=postgres

set_readonly() {
	dblist=$(psql -tU postgres -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0','template1','postgres')")
	for db in $dblist
	do
		psql -U $pguser -c "ALTER DATABASE $db SET default_transaction_read_only = true;"
	done
	RC=$?
	psql -U $pguser -c "SELCECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();"
	RC+=$?
	echo $RC
}

set_read_write() {
	#/*
	# If usage % was high and we trigger set_readonly() we want this script to keep running as normal,
	# but we don't want it to run set_readonly() again. 
	# So we only delete the lockfile when we put the db back into RW mode. 
	# This happens when we manually invoke this script with --setrw. 
	#*/
	
	dblist=$(psql -tU postgres -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0','template1','postgres')")
	for db in $dblist
	do
		psql -U $pguser -c "ALTER DATABASE $db SET default_transaction_read_only = false;"
	done
	RC=$?
	rm $lockfile
	echo $RC
}

if [[ $1 == "--setrw" ]]; then
	printf "$(date +%d_%m-%H:%M) => Attempting to set cluster to read/write.\n" >> $log
	set_rw=$(set_read_write)
	if (( $set_rw > 0 )); then 
		printf "$(date +%d_%m-%H:%M) => There was an error setting cluster to read/write.\n" >> $log
	else
		printf "$(date +%d_%m-%H:%M) => Cluster successfully set to read/write.\n" >> $log
	fi
fi

if [[ -e $lockfile ]]; then
	echo "Set readonly job already running" >> $log
	exit 
else
	# Check if disk usage % is higher than allowed and if so, call set_readonly().

	usage=$(df -h | grep -w $device | awk '{print $5}' | sed 's/%//g')
	if (( $usage > $max_allowed_usage_level )); then
		touch $lockfile
		printf "$(date +%d_%m-%H:%M) => Disk usage at %$usage. Attempting to set DB to readonly\n" >> $log
		set_ro=$(set_readonly)
		if (( set_ro > 0 )); then
			printf "$(date +%d_%m-%H:%M) => There was an error setting cluster to readonly.\n" >> $log
		else
			printf "$(date +%d_%m-%H:%M) => Cluster successfully set to readonly\n" >> $log
		fi
	else
		# When disk is not full wait five seconds. When the script exits systemd will run it again.
		sleep 5
	fi	
fi
