#!/bin/bash
RUNTIME=$(date) 
echo "\n>>> SCRIPT LAST RUN @ " $RUNTIME "\n" >> $(dirname $0)/popular_rel_dump.log 2>&1
psql planet0304 --user gcorradini -c "SELECT c.relname, count(*) AS buffers \
FROM pg_class c
    INNER JOIN pg_buffercache b ON b.relfilenode=c.relfilenode
    INNER JOIN pg_database d ON (b.reldatabase=d.oid AND d.datname=current_database())
GROUP BY c.relname
ORDER BY 2 DESC;"  >> $(dirname $0)/popular_rel_dump.log 2>&1
