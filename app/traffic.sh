#!/bin/bash
dir="/root/xray-traffic-statistics"
_APISERVER=127.0.0.1:14279
_XRAY=/usr/bin/xray/xray

apidata () {
    local ARGS=
    if [[ $1 == "reset" ]]; then
      ARGS="-reset=true"
    fi
    $_XRAY api statsquery --server=$_APISERVER "${ARGS}" \
    | awk '{
        if (match($1, /"name":/)) {
            f=1; gsub(/^"|link"|,$/, "", $2);
            split($2, p,  ">>>");
            printf "%s:%s->%s\t", p[1],p[2],p[4];
        }
        else if (match($1, /"value":/) && f){
          f = 0;
          gsub(/"/, "", $2);
          printf "%.0f\n", $2;
        }
        else if (match($0, /}/) && f) { f = 0; print 0; }
    }'
}

print_sum() {
    local DATA="$1"
    local PREFIX="$2"
    local SORTED=$(echo "$DATA" | grep "^${PREFIX}" | sort -r)
    local SUM=$(echo "$SORTED" | awk '
        /->up/{us+=$2}
        /->down/{ds+=$2}')
    local SOR=$(echo "${SORTED}" | awk -F':' '{print $2}')
    local TIM=$(echo $(date +%s))
    echo -e "${SOR}\n${SORTEF}"  | column -t >> $dir/tmp/log.log

}

DATA=$(apidata $1 )
print_sum "$DATA" "user"
