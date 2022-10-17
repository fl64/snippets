#!/usr/bin/env bash

# https://core.telegram.org/bots/api#markdown-style
# https://blog.bj13.us/2016/09/06/how-to-send-yourself-a-telegram-message-from-bash.html
# https://api.telegram.org/bot<YourBOTToken>/getUpdates


: ${SERVICE_TO_CURL:=echo:63636}
: ${SLEEP_INTERVAL:=3}


TG_CHAT_ID="<TG_CHAT_ID>"
TG_BOT_TOKEN="<TG_BOT_TOKEN>"
TG_PARSE_MODE="markdown"

trap _term SIGINT SIGTERM

tg() {
  echo "${1}"
  curl -s \
    -d parse_mode="${TG_PARSE_MODE}" \
    -d "text=${1}" "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage?chat_id=${TG_CHAT_ID}"
}


_term() {
  end=$(date +%s)
  diffSeconds="$(($end-$start))"
  diffTime=$(date -d @${diffSeconds} +"%H:%M:%S" -u)

# message
tg "
🔥 *Caught SIGTERM signal!*
🔴 *[End $(date -d @${start} +'%H:%M:%S')]*
${PROBER_INFO}
Diff in seconds: $diffSeconds.
Diff time(H:M:S): $diffTime."

  exit
}

ticker() {
  while true;do
    SS_INFO=$(ss -tlpn state ESTABLISHED | sort -k7 | head -n-1 | uniq | column -t)
    SS_INFO='```'+${SS_INFO}+'```'
    d=$(date +'%H:%M:%S')

# message
tg "🚀 [${d}]
${PROBER_INFO}
---
${SS_INFO}
---
I'm alive"

  sleep ${1}
  done
}


#=======================================================================================================================

start=$(date +%s)

# get iterration

RS_NAME=$(kubectl -n "${MY_POD_NAMESPACE}" get pods ${MY_POD_NAME} -o json | jq .metadata.ownerReferences[0].name -r)
DEPLOY_NAME=$(kubectl -n "${MY_POD_NAMESPACE}" get rs ${RS_NAME} -o json | jq .metadata.ownerReferences[0].name -r)
ITER=$(kubectl -n "${MY_POD_NAMESPACE}" get deployment ${DEPLOY_NAME} -o json | jq '.metadata.annotations."deployment.kubernetes.io/revision"' -r)


# get pod info from envs
PROBER_INFO="
🔹 *Iteration*: ${ITER}
🔹 *Service to curl:* ${SERVICE_TO_CURL}
🔹 *Namespace:* ${MY_POD_NAMESPACE}
🔹 *Deploy:* ${DEPLOY_NAME}
🔹 *ReplicaSet:* ${RS_NAME}
🔹 *Pod:* ${MY_POD_NAME}
🔹 *PodIP:* ${MY_POD_IP}
🔹 *Node:* ${MY_NODE_NAME}
🔹 *NodeIP:* ${MY_HOST_IP}
"

# get pod data
POD_DATA=$(kubectl get pods -n "${MY_POD_NAMESPACE}" "${MY_POD_NAME}" -o json | jq '. |
{
  "🔸 annotations": .metadata.annotations,
  "🔸 labels": .metadata.labels,
  "🔸 initContainers": [.spec.initContainers[].name],
  "🔸 containers": [.spec.containers[].name]
}')
POD_DATA_FORMATED='```json'+${POD_DATA}+'```'

CURL_RESULT=$(curl "${SERVICE_TO_CURL}" -qs | jq .)
CURL_RESULT_FORMATED='```json'+${CURL_RESULT}+'```'

tg "🟢 *[Start $(date -d @${start} +'%H:%M:%S')]*
---
${PROBER_INFO}
---
${POD_DATA_FORMATED}
"

#ticker 30 &

while true; do
  RESULT=$(curl -d "${POD_DATA}" "${SERVICE_TO_CURL}" -qs | jq '. | { "pod": .env.pod_name, "ver": .env.version, "node_name": .env.node_name }')
  #RESULT=$(curl -d "${POD_DATA}" "${SERVICE_TO_CURL}" -qs | jq '. | { "env": .env }')
  #echo "${RESULT}" | jq .

  RESULT_FORMATED='```json'+"${RESULT}"+'```'
  #BODY=$(echo "${RESULT}" | jq .request.body -r | jq . )

  tg "📢 ---
  ${RESULT_FORMATED}
  "
  sleep "${SLEEP_INTERVAL}"
done
