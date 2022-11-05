#!/usr/bin/env bash

K8S_API=$(kubectl config view --minify -o json --flatten | jq '.clusters[0].cluster.server ' -r)
K8S_CA=$(kubectl config view --minify -o json --flatten | jq '.clusters[0].cluster."certificate-authority-data" | @base64d' -r)
K8S_CLIENT_CRT=$(kubectl config view --minify -o json --flatten | jq '.users[0].user."client-certificate-data"| @base64d' -r )
K8S_CLIENT_KEY=$(kubectl config view --minify -o json --flatten | jq '.users[0].user."client-key-data"| @base64d' -r )

#curl  "${K8S_API}/api/v1/namespaces/echo/pods" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}")
#curl  "${K8S_API}/apis/apps/v1/deployments?watch=true" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}")

curl -s "${K8S_API}/apis/apps/v1/deployments?watch=true" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}") | while read -r deploy

api_request() {
  curl -s "${K8S_API}/${1}" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}")
}

H="Accept: application/json"

do
  printf '%s' "${deploy}" | jq '{type, ns: .object.metadata.namespace, name: .object.metadata.name, status: .object.status | del(.conditions)}' -c
  ns=$(printf '%s' "${deploy}" | jq .object.metadata.namespace -r)
  name=$(printf '%s' "${deploy}" | jq .object.metadata.namespace -r)
  #curl -s "${K8S_API}/apis/apps/v1/namespaces/${ns}/replicasets?limit=100" -H "${H}" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}") | jq .items[].metadata.name
  #curl -s "${K8S_API}/api/v1/namespaces/${ns}/pods?limit=100" -H "${H}" --cert <(echo "${K8S_CLIENT_CRT}") --key <(echo "${K8S_CLIENT_KEY}") --cacert <(echo "${K8S_CA}") | jq .items[].metadata.name

done
