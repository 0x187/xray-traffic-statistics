#!/bin/sh

#script directory
dir="/root/xray-traffic-statistics"

#Database
db_datetime="datetime('now','+04:30')"
db="$dir/database/xray.db"

#Empty log file
echo -n "" > "$dir/tmp/log.log"

#calling traffic app to save users traffic on this file: $dir/tmp/log.log
$dir/app/traffic.sh

while read first_line; read second_line
do
    #Get name, upload, download from $dir/tmp/log.log
    name=$(echo $first_line | awk -F' ' '{printf "%s\n", $1}' |  sed 's/^\(.*\)->.*$/\1/' | tr -d '\n' )
    upload=$(echo $first_line | awk -F' ' '{printf "%s\n", $2}' | tr -d '\n')
    download=$(echo $second_line  | awk -F' ' '{printf "%s\n", $2}')
    #database
    sqlite3 $db "create table [$name] (upload "INTEGER", download "INTEGER", time "TEXT");" > /dev/null  2>&1
    sqlite3 $db "insert into [$name] (upload,download,time) values ('$upload','$download',$db_datetime);" > /dev/null  2>&1

 done < "$dir/tmp/log.log"

#Empty log file
echo -n "" > "$dir/tmp/log.log"
