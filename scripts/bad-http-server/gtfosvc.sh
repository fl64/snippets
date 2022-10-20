#!/usr/bin/env bash
: ${SERVICE_PORT:=8080}

header="
HTTP/1.1 {{ STATUS }}\n
Content-Type: application/json; charset=utf-8\n
Content-Length: {{ SIZE }}\n
Date: {{ DATE }}\n
Server: GTF0\n
\n"

STATUSES=("200 OK" "500 Internal Server Error")

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

while true; do

   STATUS=$(select_random "${STATUSES[@]}")
   SIZE=$(echo -e $payload | wc -c)
   DATE=$(LC_ALL=en_EN.utf8 date -u)

   payload="
   {
      \"status\": \"${STATUS}\",
      \"msg\": \"blah\"
   }"

   echo -e "===\n${DATE}\n"
   printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
   (
      echo -e ${header} | sed -e "s/{{ STATUS }}/${STATUS}/" | sed -e "s/{{ DATE }}/${DATE}/" | sed -e "s/{{ SIZE }}/${SIZE}/"
      echo -e ${payload}
      #sh test.sh;
   ) | nc -N -lp ${SERVICE_PORT};
done
