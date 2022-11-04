#!/bin/bash
#location
dir="/root/xray-traffic-statistics"
db="$dir/database/xray.db"
db_csv="$dir/tmp/db.csv"
log="$dir/tmp/db.log"
data=$(date "+%D %H:%M")

echo -n "" > $dir/tmp/db.csv
echo -n "" > $dir/tmp/db.log


#echo "get table.."

echo -e $(sqlite3 $db .tables) | tr " " "\n" >> $log
echo "Name,Bandwidth,Expire,data,Usage" > $dir/tmp/db.csv

#echo "save to csv..."

while IFS=$'\n' read line
do

    upload=$(sqlite3 $db "SELECT SUM(upload) FROM [$line];")
    download=$(sqlite3 $db "SELECT SUM(download) FROM [$line];")
    Usage=$( expr $download + $upload | bc -l  | numfmt --suffix=B --to=iec)
    ID=$(echo $line | awk -F'[@.]' '{printf "%s\n",$1}')
    Expire=$(echo $line | awk -F'[@.]' '{printf "%s\n",$2}')
    Bandwidth=$(echo $line | awk -F'[@.]' '{printf "%s\n",$3}')
    echo "$ID,$Bandwidth,$Expire,$data,$Usage" | awk -F "," 'BEGIN {OFS=","} {print $1,$2,$3,$4,$5}' >> $db_csv
    #echo "save user ------ $line ----- to csv"
done < $dir/tmp/db.log

cat $db_csv | column -t -s, 

echo "save to cloud...."
mongoimport --uri "mongodb+srv:************" --username ** --password *** --upsertFields=Name --collection vpn --type CSV --file $dir/tmp/db.csv --headerline 2>/dev/null
echo "done"
