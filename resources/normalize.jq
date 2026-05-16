# This script for jq performs some normalization on the output of he Microformats parsers as described below

# Adds a slash to pathless URLs (e.g. "http://example.com") since URL normalization is undefined in the Microformats specification
(..|select(type=="string")) |= sub("\\b(?<url>https?://[^/ \"']+)(?=$|[ \"'])"; "\(.url)/"; "g") |
# Remove trailing slashes from void HTML elements in e- properties; this is a trivial HTML serialization difference
(.. | select(type=="object" and has("properties") and has("type")).properties[][] | select(type=="object" and has("html")).html | select(contains("/>"))) |= sub("<(?<meat>[^/ ]+( [^/=>]+(=\"[^\"]*\")*)*) */>"; "<\(.meat)>"; "g") |
# Remove unnecessary apostrophe entities; this is another trivial HTML serialization difference
(.. | select(type=="object" and has("properties") and has("type")).properties[][] | select(type=="object" and has("html")).html | select(contains("&"))) |= sub("&(#39|#[xX]27|apos);"; "'"; "g") |
# Outputs the result of the normalizations
.
