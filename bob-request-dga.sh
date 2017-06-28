#!/bin/sh

CLEINT=bob
SERVER=127.0.0.1
PORT=8000

# for dga, a timestamp (that's currently ignored)
QUERY_PAYLOAD="`date --rfc-3339=seconds | sed -e 's/ /T/'`"

QUERY='{
  "id"       : 1,
  "type"     : "dga",
  "data_type": "dga",
  "data_name": "data_dga_dir",
  "query"    : "'`echo $QUERY_PAYLOAD | base64`'"
}'

curl \
  -X POST \
  --noproxy '*' \
  --insecure \
  --data   "$QUERY" \
  --header "Content-Type: application/json" \
  --key    $CLIENT/$CLIENT.key.nopasswd \
  --cert   $CLIENT/$CLIENT.crt \
  https://$SERVER:$PORT/query
