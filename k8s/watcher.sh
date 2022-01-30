#!/usr/bin/env bash

WATCHER_FILE=./watcher-sa.yaml
K8S_CA=./k8s-ca.crt

cat << EOF > "${WATCHER_FILE}"
---
# k create sa watcher --dry-run=client -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: null
  name: watcher
---
# k create clusterrolebinding watcher-viewer --clusterrole view --serviceaccount default:watcher --dry-run=client -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: watcher-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: watcher
  namespace: default
EOF

trap ctrl_c INT

function ctrl_c() {
  echo "** Trapped CTRL-C **"
  kubectl delete -f "${WATCHER_FILE}"
  rm "${WATCHER_FILE}" "${K8S_CA}"
}

kubectl apply -f "${WATCHER_FILE}"
SERVICE_ACCOUNT=watcher # Get the ServiceAccount's token Secret's name
SECRET=$(kubectl get serviceaccount ${SERVICE_ACCOUNT} -o json | jq -Mr '.secrets[].name | select(contains("token"))')
TOKEN=$(kubectl get secret ${SECRET} -o json | jq -Mr '.data.token' | base64 -d)
kubectl get secret ${SECRET} -o json | jq -Mr '.data["ca.crt"]' | base64 -d > "${K8S_CA}"
APISERVER=https://$(kubectl -n default get endpoints kubernetes --no-headers | awk '{ print $2 }')


curl -s "$APISERVER/api/v1/events?watch=true" --header "Authorization: Bearer $TOKEN" --cacert "${K8S_CA}" | while read -r event
do
  printf '%s' "${event}" | jq .object.metadata.name
done
