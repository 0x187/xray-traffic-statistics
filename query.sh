#!/bin/bash
#location
dir='/home/sr/project/xray'
db="$dir/database/xray.db"
db_csv="$dir/tmp/db.csv"
log=$(< $dir/tmp/db.log)
data=$(date "+%D %H:%M")

echo "get table.."

echo -e $(sqlite3 $db .tables) | tr " " "\n" > $dir/tmp/db.log
echo -n "" > $dir/tmp/db.csv

echo "Name,Bandwidth,Expire,data,Usage" > $dir/tmp/db.csv

line=$(echo "$log" | wc -l)
COUNTER="1"

echo "save to csv..."

while [ $COUNTER -le $line ]; do
    name=$(echo "$log" |sed -n "${COUNTER}"p)
    upload=$(sqlite3 $db "SELECT SUM(upload) FROM [$name];")
    download=$(sqlite3 $db "SELECT SUM(download) FROM [$name];")
    Usage=$(echo "$download + $upload" | bc -l  | numfmt --suffix=B --to=iec)
    ID=$(echo $name | awk -F'[@.]' '{printf "%s\n",$1}')
    Expire=$(echo $name | awk -F'[@.]' '{printf "%s\n",$2}')
    Bandwidth=$(echo $name | awk -F'[@.]' '{printf "%s\n",$3}')
    echo "$ID,$Bandwidth,$Expire,$data,$Usage" | awk -F "," 'BEGIN {OFS=","} {print $1,$2,$3,$4,$5}' >> $db_csv
    echo "save user ------ $name ----- to csv"
    let COUNTER=COUNTER+1 
done

echo "save to cloud...."
mongoimport --uri <mongodb atlass ulr> --upsertFields=Name  --collection vpn --type CSV --file $dir/tmp/db.csv --headerline 2>/dev/null
echo "done"



