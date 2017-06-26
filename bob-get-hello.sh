#!/bin/sh

CLIENT=bob
SERVER=127.0.0.1
PORT=8000

curl \
  -X GET \
  --noproxy '*' \
  --include \
  --insecure \
  --key    $CLIENT/$CLIENT.key.nopasswd \
  --cert   $CLIENT/$CLIENT.crt \
  https://$SERVER:$PORT
