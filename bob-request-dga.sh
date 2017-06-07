#!/bin/sh

# for dga, a timestamp (that's currently ignored)
QUERY_PAYLOAD="`date -Iseconds`"

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
  --key    bob/bob.key.nopasswd \
  --cert   bob/bob.crt \
  https://127.0.0.1:8080/query
