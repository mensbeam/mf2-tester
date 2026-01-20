import mf2py
import sys
import json
if len(sys.argv) < 2:
    print('usage: '+ sys.argv[0]+ ' <inputfile> <outputfile>')
    sys.exit(1)

name = sys.argv[1]
base = 'http://example.com/'
if "/microformats-v2-unit/" in name:
    # This is a unit test; these use a different base URL
    base = 'http://example.test'

with open(name,'r') as file:
    p = mf2py.Parser(doc=file, url=base)
    res = json.loads(p.to_json())
    del res['debug']
    print(json.dumps(res))

