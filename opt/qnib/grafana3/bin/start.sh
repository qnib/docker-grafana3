#!/bin/bash

DB_PATH=${GRAFANA_DB_PATH-/var/lib/grafana/grafana.db}
DASH_PATH=${GRAFANA_DASH_PATH-/opt/qnib/grafana3/dashboards/}
if [ ! -z ${GRAFANA_DEFAULT_SOURCE} ];then
    source_cnt=$(sqlite3 ${DB_PATH} "SELECT count(id) FROM data_source WHERE name = '${GRAFANA_DEFAULT_SOURCE}';")
    if [ ${source_cnt} -eq 1 ];then
        sqlite3 ${DB_PATH} "UPDATE data_source SET is_default=0;"
        sqlite3 ${DB_PATH} "UPDATE data_source SET is_default=1 WHERE name = '${GRAFANA_DEFAULT_SOURCE}';"
    else
        echo "GRAFANA_DEFAULT_SOURCE (${GRAFANA_DEFAULT_SOURCE}) is either not present or has more then one match..."
    fi
fi
### inserts dashboards
DASH_TIME=$(date +"%F %H:%M:%S")
for dash in $(find ${DASH_PATH} -name \*.json);do
    echo $dash
    DASH_TITLE=$(jq '.title' $dash |sed -e 's/"//g')
    DASH_SLUG=$(echo $dash |awk -F/ '{print $NF}' | sed -e 's/\.json$//')
    DASH_DATA=$(jq -c "." ${dash})
    sqlite3 ${DB_PATH} "INSERT INTO dashboard (created, updated, version, slug, title, org_id, data) VALUES ('${DASH_TIME}', '${DASH_TIME}', '0', '${DASH_SLUG}', '${DASH_TITLE}','1','${DASH_DATA}');"
done


sleep 2
/usr/sbin/grafana-server --pidfile=/var/run/grafana-server.pid --config=/etc/grafana/grafana.ini cfg:default.paths.data=/var/lib/grafana cfg:default.paths.logs=/var/log/grafana
