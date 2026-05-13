import mf2dom
import sys
import json

if len(sys.argv) < 3:
    print('usage: '+ sys.argv[0]+ ' <input_file> <base_url>')
    sys.exit(1)

name = sys.argv[1]
base = sys.argv[2]

with open(name,'r') as file:
    p = mf2dom.parse(file.read(), base_url=base)
    print(json.dumps(p))
