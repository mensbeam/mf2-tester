# This script for jq performs some normalization on the output of he Microformats parsers as described below

# Adds a slash to pathless URLs (e.g. "http://example.com") since URL normalization is undefined in the Microformats specification
(..|select(type=="string")) |= sub("\\b(?<url>https?://[^/ \"']+)(?=$|[ \"'])"; "\(.url)/"; "g") |
# Outputs the result of the normalizations
.
