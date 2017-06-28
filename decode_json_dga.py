#!/usr/bin/env python
# decode_json_dga.py: reads data from stdin, outputs to a file
#
# expected input json format:
#     
# {
#   "dga":
#   [
#     {"name": "CnC_2017_00_00-example-example-IPDomainList",
#     "data": "base64-encoded data of IP:domain pairs"},
#     {"name": "CnC_2017_00_00-example2-example2-IPDomainList",
#     "data": "base64-encoded data of IP:domain pairs"}
#   ]
# }

import json
import sys
import base64

jdata = sys.stdin.read()

# sometimes we have http headers before json
jdata = jdata[ jdata.index('{') : ]

# kind of annoying if we didn't format json properly
data = json.loads(jdata.replace("\'", '"'))

for entry in data['dga']:
    payload = entry['data'].decode('base64')
    filename = entry['name']
    
    with open(filename, 'w') as f:
        f.write(payload)
    
    if f.closed:
        print "wrote results to %s" % filename
