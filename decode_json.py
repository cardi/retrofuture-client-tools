#!/usr/bin/env python
# decode_json.py: reads data from stdin, outputs "results" to stdout decoded payload

import json
import sys
import base64
from pprint import pprint

jdata = sys.stdin.read()

# sometimes we have http headers before json
jdata = jdata[ jdata.index('{') : ]

# kind of annoying if we didn't format json properly
data = json.loads(jdata.replace("\'", '"'))

data['results'] = data['results'].decode('base64')

print data['results']
