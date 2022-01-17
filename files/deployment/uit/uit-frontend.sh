#!/bin/bash

HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -f`}"
INTERVAL="${COLLECTD_INTERVAL:-10}"

while sleep "${INTERVAL}"
do
    uit_frontend_pid=$(/usr/bin/pgrep -f "/usr/bin/node ../../node_modules/nuxt/bin/nuxt.js")
    memory_used_kbytes=$(ps -h -o rss -${uit_frontend_pid})

    echo "PUTVAL ${HOSTNAME}/uit-frontend/memory_used interval=${INTERVAL} N:${memory_used_kbytes}"
done
