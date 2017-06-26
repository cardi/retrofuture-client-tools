# retrofuture-client-tools

* [retrofuture-client-tools](#retrofuture-client-tools)
   * [generate a TLS client certificate](#generate-a-tls-client-certificate)
   * [sending requests](#sending-requests)
      * [hello world](#hello-world)
      * [dga botnet activity lists](#dga-botnet-activity-lists)
   * [parsing responses](#parsing-responses)
      * [parsing dga responses](#parsing-dga-responses)

## generate a TLS client certificate

Retro-Future uses TLS client certificates for authentication and signing
of HTTP requests.

We need to generate a private key (keep safe) and a certificate signing
request (CSR), which we'll keep in a new directory `$CLIENT`:

```bash
export CLIENT=alice
mkdir -p $CLIENT
openssl genrsa -des3 -out $CLIENT/$CLIENT.key 4096
openssl req -new -key $CLIENT/$CLIENT.key -out $CLIENT/$CLIENT.csr
```

Send the `.csr` file to the system administrator, who will generate a
CA-signed client certificate that you'll use with all your requests with
the following command:

```bash
openssl x509 \
  -req \
  -days 3650 \
  -extfile openssl.conf \
  -extensions ssl_client \
  -in $CLIENT/$CLIENT.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -set_serial $SERIAL \
  -out $CLIENT/$CLIENT.crt
```

Optionally you can remove the password to your private key
(this makes it easier to automate and script requests):

```bash
openssl rsa -in $CLIENT/$CLIENT.key  -out $CLIENT/$CLIENT.key.nopasswd
```

## sending requests

Requests are sent using HTTP `POST` commands with a JSON-encoded query.

### hello world

First try [bob-get-hello.sh](./bob-get-hello.sh) (replace `127.0.0.1`
with the actual server) to test if your certificates are working
properly.

The script simply sets a `GET` command to the server.

If everything goes well, you should get a `200 OK` and the following
JSON response:

```json
{
  "msg": "hello BOB! we read you loud and clear."
}
```

If not authorized, you will get the following reply:

```http
HTTP/1.1 401 Unauthorized
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Wed, 07 Jun 2017 19:17:40 GMT
Content-Length: 14

Unauthorized.
```

### dga botnet activity lists

We'll walk through an example using requests for DGA botnet activity
data, an example is provided in [bob-request-dga.sh](./bob-request-dga.sh).

An example JSON payload (note that the `query` value is base64-encoded):

```json
{
  "id": 1,
  "type": "dga",
  "data_type": "dga",
  "data_name": "data_dga_dir",
  "query": "MjAxNy0wNi0wN1QxNDoxNDowMy0wNTowMAo="
}
```

We save this to an environment variable and wrap the query with `curl`:

```bash
curl \
  -X POST \
  --noproxy '*' \
  --insecure \
  --data   "$QUERY" \
  --header "Content-Type: application/json" \
  --key    bob/bob.key.nopasswd \
  --cert   bob/bob.crt \
  https://127.0.0.1:8080/query
```

The [example script provided](./bob-request-dga.sh) will take care of
encoding the payload and formatting the JSON-encoded query.

## parsing responses

Authorized requests will return JSON-formatted answers, with the
`results` value base64-encoded.

In general, the response is formatted:

```json
{
  "id": 1,
  "msg": "query successful",
  "response_level": 3,
  "results": "eyJuYW1lIjoiQ25DXzIwMTdfMDVfMzEtc2FtcGxlLXNhbXBsZS1JUERvbWFpbkxpc3QiLCJkYXRhIjoiTWpBeE53bz0ifQ=="
}
```

[decode_json.py](./decode_json.py) will automatically extract and decode
the value of `results` and print them to STDOUT.

### parsing `dga` responses

**Summary**: `cat output.json | ./decode_json.py | ./decode_json_dga.py`

The format of `results` depends on the query `type`.

At the moment, we're working only with the `dga` query type.
The format of the results is the following:

```json
{
  "name": "CnC_2017_05_31-sample-sample-IPDomainList",
  "data": "MjAxNwo="
}
```

Another script [decode_json_dga.py](./decode_json_dga.py) will automatically
extract and decode this "second layer" of results and save them (`data`) to a
file (named `name`).

`name` is the filename of the botnet activity list, which is useful for
cross-referencing with the data owner.

`data` is the base64-encoded file. The timestamp in the `name`
corresponds to the date the data was published and contains a 30-day
rollup of activity seen.

The IPDomainList data is a plaintext file formatted with
`IP: domain1, domain2, ..., domainN` entries, separated by
newlines.

```
10.0.0.1: a.example.com,b.example.com,c.example.com
10.0.0.2: example.com,www.example.com
```

There are additional scripts to working with botnet activity lists not
provided here.
