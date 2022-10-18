# Snippets

## Testing

Useful services for testing online

- jq https://jqplay.org/
- go template https://repeatit.io/
- go https://goplay.space/
- k8s YAML generator https://k8syaml.com/

Upload from CLI

- https://bashupload.com/
- https://0x0.st/
- https://transfer.sh/
- https://hastebin.com/about.md

## Bash

Redirect

```bash
# Redirect stderr to stdout
cmd 2>&1
# Redirect stdout to stderr
cmd 1>&2
## stderr and stdout to file
cmd 1>combined.log 2>&1
```

Show unix time 2 months ago

```bash
date +%s -d '2 months ago'
```

Show time in format YYYY-MM-DD-hh-mm-ss

```bash
date "+%F-%H-%M-%s"
```

find files accessed 5 min ago

```bash
find . -cmin -5
```

find logs for 2 days and tar it

```bash
find logs/ -mtime -2 -type f | xargs -d "\n" tar cvfz $(date "+%F-%H-%M-%S")-logs.tar.gz
```

find Revision: field in all y(a)ml files

```bash
find . -name '*.yml' -o -name '*.yaml' -print0 | xargs -0 grep 'Revision:' | grep -v depricated
```

find all catalogs with helm charts and lint them

```bash
find apps/ -mindepth 1 -maxdepth 1  -type d | xargs -I %HELMCHART% bash -c "helm dependency build %HELMCHART% && helm lint --with-subcharts --debug %HELMCHART%"
```

find | grep and check

```bash
find . -name '*.yml' -o -name '*.yaml' -print0 | xargs -0 grep -E '(R|r)evision: .+' | grep -vE '(depricated|HEAD)' || EXIT_CODE=$?
```

find and delete

```bash
find / -name .terraform -exec rm -rf {} \;
find . -name ".terraform" -print0 | xargs -I {} -0 rm -rf "{}"
```

loop over array vars with suffix

```bash
declare -A HTTP_CHECK_1=([addr]=google.com [port]=443)
declare -A HTTP_CHECK_2=([addr]=example.com [port]=383)

declare -A SIP_CHECK_1=([addr]=1.1.1.1 [port]=5060)
declare -A SIP_CHECK_2=([addr]=2.2.2.2  [port]=5060)

for _CHECK in $(compgen -v | grep -xE '(HTTP|SIP)_CHECK_.*'); do
   declare -n p="$_CHECK"
   echo "${p[addr]}"
done
```

logging to syslog

```bash
exec > >(tee >(logger  -p local0.notice -t $(basename "$0")))
exec 2> >(tee >&2 >(logger  -p local0.error -t $(basename "$0")))
```

wait for changes and do something (POST for example)

```bash
while true; do
   inotifywait "$(readlink -f $1)"
   echo "[$(date +%s)] Trigger refresh"
   curl -sSL -X POST "$2" > /dev/null
done
```

read ssh keys from variables starting from 'SSHKEY\_'

```bash
for key in "${!SSHKEY_@}"; do
    ssh-add <(echo "${!key}")
done
```

heredoc to var

```bash
read -r -d '' CONFIG <<EOF
{ "cluster_name":
  {
    "config":
      {
        "p1": "${VAR1}",
        "p2": "${VAR2}",
      }
  }
}
EOF
```

sort by semver

```bash
printf "1.0\n2.0\n2.12\n2.10\n1.2\n1.10" | sort -t "." -k1,1n -k2,2n -k3,3n
```

trap a signal

```bash
#!/bin/bash

trap "echo 'Terminating';exit" INT TERM

echo "PID: $$"
while true
do
    echo "$(date +'%H:%M')"
    sleep 10
done
```

trap a signal v2

```bash
trap _term SIGINT SIGTERM

_term() {
  echo 'Terminating'
  exit
}

```

random number in range

```bash
shuf -i 10-70 -n 1
```

fill up 90% memory

```bash
stress-ng --vm-bytes $(awk '/MemFree/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1
```

set default editor

```bash
export EDITOR='subl -w'
ansible-vault edit ...
```

get script working dir

```bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
```

script execution time

```bash
start=$(date +%s)
sleep 10
end=$(date +%s)
diffSeconds="$(($end-$start))"
diffTime=$(date -d @${diffSeconds} +"%H:%M:%S" -u)
echo "Diff in seconds: ${diffSeconds}."
echo "Diff time(H:M:S): ${diffTime}."
```

### system

journalctl get docker logs

```bash
journalctl -u docker -o json | jq -cMr 'select(has("CONTAINER_ID") | not) | .MESSAGE'
```

boot

```bash
journalctl --list-boots
journalctl -b -1 #last boot
```

priority

```bash
journalctl -b -1  -p "emerg".."crit" # output all messages with priority between emergency and critical from last boot
journalctl -b -1  -p 0..2 the same
journalctl -p 4 # from error level error
```

time

```bash
journalctl -n 50 --since "1 hour ago" # last 50 messages logged within the last hour
journalctl --since "2015-06-26 23:15:00" --until "2015-06-26 23:20:00" # system time spec: https://www.freedesktop.org/software/systemd/man/systemd.time.html
```

reverse

```bash
journalctl -u docker -r list in reverse order
```

### git

git diff to folder

```bash
git -C some/code/app diff --relative HEAD~ # relative path in patch file
git -C some/code/app diff  HEAD~ > app.patch # full path
git apply app.patch
```

using oath2 token instead of password

```bash
git config --global url."https://oauth2:${TOKEN}@gitlab.com/".insteadOf https://gitlab.com/
```

create MR on gitlab

```bash
git push \
    -o merge_request.create \
    -o merge_request.target=master \
    -o merge_request.title="switch to ${CI_COMMIT_TAG}" \
    -o merge_request.description="${DESCRIPTION//$'\n'/<br />}" \
    "https://oauth2:${TOKEN}@gitlab.com/${DEST_GROUP}/${DEST_REPO}.git" \
    "${NEW_BRANCH}"
```

delete tag localy and remotely

```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

delete tag localy and remotely v2

```bash
git push --delete origin v1.0.0
git tag -d v1.0.0
```

### networking

ssh ignore known hosts for vagrant

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i .vagrant/machines/test00/virtualbox/private_key vagrant@192.168.56.99
```

scan ssh keys

```bash
ssh-keyscan -p 2222 gitlab.example.ru
```

open remote server port on local machine

```bash
ssh <remote_host> -N -f -L <local_port>:127.0.0.1:<repote_port>
```

check port verbosely

```bash
nc -vzw 2 server.example.com 8500
```

get ssl certificate from web

```bash
echo | openssl s_client -showcerts -servername 10.3.0.17 -connect 10.3.0.17:443 2>/dev/null | openssl x509 -inform pem -noout -text
```

curl via ip

```bash
curl https://example.com --resolve 'example.com:443:192.0.2.17'
```

curl and untar

```bash
sudo bash -c "curl -L https://github.com/cilium/cilium-cli/releases/download/v0.12.4/cilium-linux-amd64.tar.gz | tar -xz -C /usr/local/bin/"
```

send email with curl

```bash
curl --ssl-reqd \
  --url 'smtps://smtp.gmail.com:465' \
  --user 'username@gmail.com:password' \
  --mail-from 'username@gmail.com' \
  --mail-rcpt 'john@example.com' \
  --upload-file /dev/null
```

get all TCP-packets with RST flag https://serverfault.com/questions/217605/how-to-capture-ack-or-syn-packets-by-tcpdump

```bash
tcpdump "tcp[tcpflags] & (tcp-rst) != 0"
tcpdump "(net 10.1.2.0/24 or 10.2.2.0/24) and tcp[tcpflags] & (tcp-rst) != 0"
```

find pattern in network traffic

```bash
ngrep -iq "/ping.*user-agent" "port 80" -W byline
```

### docker

remove all older than

```bash
docker system prune --filter 'until=168h' --all -f
```

docker image format

```bash
docker images --format "{{ .ID}} {{.Repository }}:{{ .Tag}}"
```

### k8s

get node names

```bash
NODES=$(kubectl get nodes -o json | jq '.items[].metadata.name' -r | tr '\n' ' ')

# get node ip

for NODE in ${NODES}; do
  kubectl get nodes "${NODE}" -o json | jq '.status.addresses[0].address' -r
done

```

git images

```bash
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```

k8s delete ns with finalizers

```bash
NAMESPACE=argocd-system
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
```

wait for node

```bash
kubectl wait --for condition=ready -l node-role.kubernetes.io/control-plane node
kubectl wait --for condition=ready -l node-role.kubernetes.io/master node
kubectl wait --for condition=ready node --all --timeout=10s
```

wait for pod

```bash
kubectl wait --for=condition=ready pod -l app=someappwait for job
kubectl wait --for=condition=complete --timeout=30s -n namespace job/some-job
```

exec to some shell

```bash
kubectl exec -i -t -n default pt-test-pod -c test-pod "--" sh -c "clear; (bash || ash || sh)"
```

limits requests

```bash
kubectl get pods -o=custom-columns=NAME:spec.containers[*].name,MEMREQ:spec.containers[*].resources.requests.memory,MEMLIM:spec.containers[*].resources.limits.memory,CPUREQ:spec.containers[*].resources.requests.cpu,CPULIM:spec.containers[*].resources.limits.cpu
```

get cadvisor metrics

```bash
kubectl proxy --port 8888 & curl -s http://localhost:8888/api/v1/nodes/${NODE_NAME}/proxy/metrics/cadvisor
```

heredoc apply

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: httpbin
  namespace: demo-service
  labels:
    app: httpbin
spec:
  containers:
  - name: httpbin
    image: kennethreitz/httpbin
    ports:
      - containerPort: 80
EOF
```

### yc

remove all yc profile by mask

```bash
yc config profile list | grep "${PROFILE_NAME}" | xargs -L 1 yc config profile delete
```

get cloud-id

```bash
yc --profile="${PROFILE_NAME}" config get cloud-id
```

get k8s cluster id

```bash
yc --profile="${PROFILE_NAME}" managed-kubernetes cluster list --format json | jq '.[].id' -r
```

get instances ids for yc k8s node group

```bash
yc managed-kubernetes node-group list-nodes "group-1a" --profile="${PROFILE_NAME}" --format json | jq '.[].kubernetes_status.id'
```

### tf

edit terraform state

```bash
terraform state pull > tf.state
vi tf.state # (don't forget increase serial)
terraform state push tf.state
```

## Jq

select records with .level is "info|error|warn" and .msg is not contain "deprecated"

```bash
jq '. | select(.level | test("info|error|warn")) | select(.msg | test(".+deprecated.+") | not )
```

select records with worker label exist and have addr type InternalIP

```bash
jq '.items[] | select(.metadata.labels."node-role.kubernetes.io/worker"!=null) | .status.addresses | .[] | select (.type=="InternalIP") | .address' -r
```

using args

```bash
jq --arg name "istiod-v1x13" '.items[] | .metadata | select( .name | test($name)) | .name' -r
jq --arg revision v1x13 '.items[] | select( .spec.revision == $revision ) | .metadata.name' -r
```
