#!/bin/bash
TIMESTAMP=$(date)
echo ""
echo ""
echo "####################################################################"
echo "SAMPLE @ >>> " $TIMESTAMP
echo "####################################################################"
echo ""
echo ""
echo "######## vmstat output #########################"
vmstat 1 15
#echo "######## process tree for user postgres  #######"
#ps -ALF | sort -nr -k 4 | head -30
#ps -U postgres -H
echo "######## process tree -F user postgres #########"
ps -U postgres -jHF
#echo "######## thread listing for user postgres ######"
#ps -ALF | sort -nr -k 3 | head -30
#ps -U postgres -LF
echo "######## process size/thread cnt postgres ######"
ps -U postgres -o pid,nlwp,vsz,args
#echo "######## free output by MB  ####################"
#free -m
#echo "######## loading average #######################"
#uptime

