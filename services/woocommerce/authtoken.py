#!/usr/bin/env python3
import sys
from base64 import b64encode

username=sys.argv[1]
password=sys.argv[2]
encode=b64encode(bytes(username+ ':' +password,"utf-8")).decode("ascii")

print("{u'11111111-11111-1111-1111-11111111': {}}")
print( 'Authorization: Basic',encode)
