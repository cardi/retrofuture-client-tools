#!/bin/sh

CLIENT=bob

curl \
  -X GET \
  --noproxy '*' \
  --include \
  --insecure \
  --key    $CLIENT/$CLIENT.key.nopasswd \
  --cert   $CLIENT/$CLIENT.crt \
  https://127.0.0.1:8080
