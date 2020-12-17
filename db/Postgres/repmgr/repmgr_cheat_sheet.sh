/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf daemon pause
/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf cluster show
/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf daemon status
/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf node rejoin -d 'host=hostname.com dbname=repmgr user-repmgr' --force-rewind --config-files=postgresql.conf,pg_hba.conf,server.crt,server.key

--# Standby clone
sudo su - postgres
cp /var/lib/pgsql/11/data/{postgresql.conf,pg_hba.conf,server.key,server.crt} /tmp/
rm -rf /var/lib/pgsql/11/data/
exit
sudo su - 
rm -rf /temp_tbs/*
exit
sudo su - postgres
/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf standby clone -h hostname.com -U repmgr -d repmgr -f
cp /tmp/{postgresql.conf,pg_hba.conf,server.key,server.crt}  /var/lib/pgsql/11/data/
exit
sudo systemctl start postgresql-11
sudo su - postgres
/usr/pgsql-11/bin/repmgr -f /etc/repmgr/11/repmgr.conf standby register --force
exit
