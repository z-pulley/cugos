#!/bin/bash
RUNTIME=$(date) 
LOGNAME=buff_distro_dump.log

echo "\n>>> SCRIPT LAST RUN @ " $RUNTIME "\n" >> $(dirname $0)/$LOGNAME 2>&1
psql planet0304 --user gcorradini -c "SELECT \
c.relname, count(*) AS buffers,usagecount
FROM pg_class c
INNER JOIN pg_buffercache b
ON b.relfilenode = c.relfilenode
INNER JOIN pg_database d
ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.relname,usagecount
ORDER BY c.relname,usagecount;" >> $(dirname $0)/$LOGNAME  2>&1

