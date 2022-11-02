#!/usr/bin/env bash

: ${SERVICE_TO_CURL:=echo:63636}
: ${SLEEP_INTERVAL:=3}
: ${JQ_QUERY:='. | { "pod": .env.pod_name, "ver": .env.version, "node_name": .env.node_name }'}

while true; do
  curl  "${SERVICE_TO_CURL}" -qs | jq "${JQ_QUERY}"
  sleep "${SLEEP_INTERVAL}"
done
