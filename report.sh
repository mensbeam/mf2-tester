#!/bin/bash

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null

TEST_SUITE_VERSION=`git ls-tree HEAD --abbrev | grep $'\t''mf2-tests$' | cut -d ' ' -f 3 | cut -f 1`;
lang_dir="`pwd`/languages"
declare -i TOTAL=0

# change the working directory; this will simplify much of what we have to do
pushd results >/dev/null

# keep track of the number of passed tests for each language
pushd libs >/dev/null
declare -a LANGUAGES=(*)
declare -A COUNTS
for lang in ${LANGUAGES[@]}; do
    declare -i COUNTS["$lang"]=0
done
popd >/dev/null

# Prepare the table body; this consists of one row for each test
TBODY='<tbody>'
for f in test-results/*/*/*.json ; do
    TOTAL=$((TOTAL + 1))
    TBODY+="<tr>"
    # compute the fixed part of the file name
    FILE=${f#"test-results"}
    FILE=${FILE%".json"}
    # prepare the cell with the test input
    TEST_URL="tests$FILE.txt"
    NAME=`echo "$FILE" | sed -e 's#^/##' -e 's#/#<br>#g'`
    TBODY+='<td><a href="'$TEST_URL'">'$NAME'</a>'
    # prepare the cell with the expected output
    EXP_URL="test-results$FILE.json"
    EXP_MD5=`md5sum "$f" |cut -d ' ' -f 1`
    TBODY+='<td>Expected: <a href="'$EXP_URL'">View</a><div class="md5" title="'$EXP_MD5'">'$EXP_MD5'</div><div class="diff"><wbr></div>'
    # prepare a result cell for each language
    for lang in ${LANGUAGES[@]}; do
        RESULT_URL="libs/$lang$FILE.json"
        RESULT_ERR="libs/$lang$FILE.err.txt"
        RESULT_DIFF="libs/$lang$FILE.diff.txt"
        if [ -s "$RESULT_ERR" ]; then
            # the test program produced an error; skip MD5 computation and diffing
            TBODY+='<td class="error">Result: <a href="'$RESULT_ERR'">Error</a><div class="md5"><wbr></div><div class="diff"><wbr></div>'
            rm -f "$RESULT_URL"
        else
            rm -f "$RESULT_ERR"
            RESULT_MD5=`md5sum "$RESULT_URL" |cut -d ' ' -f 1`
            if [ "$RESULT_MD5" = "$EXP_MD5" ]; then
                # the test passed; increment the number of passed tests
                COUNTS["$lang"]=$((${COUNTS["$lang"]} + 1))
                TBODY+='<td class="pass">Result: <a href="'$RESULT_URL'">Pass</a><div class="md5" title="'$RESULT_MD5'"><wbr></div><div class="diff"><wbr></div>'
            else
                # the test failed; produce a diff and link to that in addition to the result
                diff -y --left-column "$EXP_URL" "$RESULT_URL" > "$RESULT_DIFF"
                TBODY+='<td class="fail">Result: <a href="'$RESULT_URL'">Fail</a><div class="md5" title="'$RESULT_MD5'">'$RESULT_MD5'</div><div class="diff"><a href="'$RESULT_DIFF'">Diff</a></div>'
            fi
        fi
    done
done
# restore the working directory and change to where package registry files are
popd >/dev/null
pushd deps >/dev/null

# next prepare the table header
THEAD='<thead>'
# the first row contains library names and versions
THEAD+='<tr><th rowspan="2">Test<th><a href="https://github.com/microformats/tests">Test Suite</a><div class="version">'$TEST_SUITE_VERSION'</div>'
for lang in ${LANGUAGES[@]}; do 
    NAME=`cat "$lang_dir/${lang}/label"`
    LINK=`cat "$lang_dir/${lang}/link"`
    VERSION=`source "$lang_dir/${lang}/version.sh"`
    THEAD+='<th><a href="'$LINK'">'$NAME'</a><div class="version">'$VERSION'</div>'
done
# the second row contains test counts
THEAD+='<tr><td>'$TOTAL' tests'
for lang in ${LANGUAGES[@]}; do 
    THEAD+='<td>'${COUNTS["$lang"]}' passed'
done

# restore the working directory and output the document
popd >/dev/null
echo '
<!DOCTYPE html>
<html>
<head>
<title>Microformats testing report</title>
<style>
.pass {
    background-color: lightgreen;
}
.fail {
    background-color: lightgrey;
}
.error {
    background-color: lightpink;
}
table, th, td {
    border: 1px solid black;
    text-align: center;
}
th, td {
    padding: 0 1ex;
}
.md5, .diff{
    font-size: x-small;
}
.md5 {
    font-family: monospace;
    width: 13ex;
    margin: auto;
    overflow: hidden;
    text-overflow: ellipsis;
}
</style>
<body>
<h1>Test Results</h1>
<p><a href="https://github.com/dissolve/mf2-tester">Source</a>
<table>'$THEAD$TBODY'
</table>' | sed -E -e 's/<t(head|body)/\n  \0/g' -e 's/<tr/\n    \0/g' -e 's/<t[dh][ >]/\n      \0/g' > results/index.html
