import mf2py
import sys
import json

if len(sys.argv) < 3:
    print('usage: '+ sys.argv[0]+ ' <input_file> <base_url>')
    sys.exit(1)

name = sys.argv[1]
base = sys.argv[2]

with open(name,'r') as file:
    p = mf2py.Parser(doc=file, url=base)
    res = json.loads(p.to_json())
    del res['debug']
    print(json.dumps(res))
