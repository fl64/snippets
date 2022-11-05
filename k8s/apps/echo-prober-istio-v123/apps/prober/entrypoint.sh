#!/usr/bin/env bash

: ${HEADER:="XXX: YYY"}
: ${JQ_QUERY:="{ ver: .env.version, node: .env.node_name, sa: .env.service_account }"}

while true; do
  curl --max-time 10 --connect-timeout 10 -sq -XGET "${SERVICE_TO_CURL}" -H"${HEADER}" | jq "${JQ_QUERY}"
  sleep ${SLEEP_TIMEOUT:-0.1}
done
