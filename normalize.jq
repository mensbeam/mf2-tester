# Apply f to composite entities recursively using keys[], and to atoms
def sorted_walk(f):
  . as $in
  | if type == "object" then
      reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | sorted_walk(f)) } ) | f
  elif type == "array" then map( sorted_walk(f) ) | f
  else f
  end;

def normalize: sorted_walk(if type == "array" then sort else . end);

normalize |
(..|select(type=="string")) |= sub("\\b(?<url>https?://[^/ \"']+)(?=$|[ \"'])"; "\(.url)/"; "g") |
(.rels,."rel-urls",(..|select(type=="object" and has("properties")).properties)) |= if length < 1 then {} else . end |
.
