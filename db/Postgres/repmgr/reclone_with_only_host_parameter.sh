rm -rf /var/lib/pgsql/10/data/*
PGPASSWORD=Yeswecan2015 /usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf -h $1 -U repuser -d postgres standby clone --force-rewind --force
sudo systemctl restart postgresql-10
/usr/pgsql-10/bin/repmgr -f /etc/repmgr/10/repmgr.conf standby register --force
