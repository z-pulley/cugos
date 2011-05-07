#!/bin/bash
RUNTIME=$(date) 
LOGNAME=sum_usage_dump.log

echo "\n>>> SCRIPT LAST RUN @ " $RUNTIME "\n" >> $(dirname $0)/$LOGNAME 2>&1
psql planet0304 --user gcorradini -c "SELECT usagecount, count(*), isdirty \
FROM pg_buffercache \
GROUP BY isdirty,usagecount \
ORDER BY isdirty,usagecount;" >> $(dirname $0)/$LOGNAME  2>&1

