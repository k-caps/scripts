createdb pgbench
psql -d pgbench -c "CREATE TABLE benchmarker as select a.* from pg_stat_activity a, pg_stat_activity b, pg_stat_activity c, pg_stat_activity d, pg_stat_activity e;"
echo "select * from benchmarker a, benchmarker b, benchmarker c, benchmarker d, benchmarker e;"  > /var/lib/postgresql/pgbench_script.sql
pgbench -U postgres -n pgbench -f /var/lib/postgresql/pgbench_script.sql -j 2 -t 50  -T 1800
dropdb pgbench
