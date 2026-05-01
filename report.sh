#!/usr/bin/env bash

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null

TEST_SUITE_VERSION=`git ls-tree HEAD --abbrev | grep $'\t''mf2-tests$' | cut -d ' ' -f 3 | cut -f 1`;
base_dir=`pwd`
lang_dir="$base_dir/languages"

# get the list of "languages" (parser libraries)
pushd results/libs >/dev/null
declare -a LANGUAGES=(*)
popd >/dev/null

function make_table {
    pushd results >/dev/null
    # keep track of the number of passed tests for each language
    local -A COUNTS
    for lang in ${LANGUAGES[@]}; do
        local -i COUNTS["$lang"]=0
    done
    local -i TOTAL=0
    # Prepare the table body; this consists of one row for each test
    local TBODY='<tbody>'
    for f in $@ ; do
        # compute the fixed part of the file name
        local FILE=${f#"test-results"}
        FILE=${FILE%".json"}
        # determine whether the test is a tentative one; these are tests which implementations are not expected to pass because correct behavious is undefined
        local TENTATIVE=`grep -E '/microformats-v2-unit/[^/]+/tentative-' <<< "$FILE"`
        # begin the row
        TOTAL=$((TOTAL + 1))
        TBODY+="<tr>"
        # prepare the cell with the test input
        TEST_URL="tests$FILE.txt"
        local NAME=`echo "$FILE" | sed -e 's#^/##' -e 's#/#<br>#g'`
        TBODY+='<td><a href="'$TEST_URL'">'$NAME'</a>'
        # prepare the cell with the expected output
        local EXP_URL="test-results$FILE.json"
        local EXP_MD5=`md5sum "$f" |cut -d ' ' -f 1`
        TBODY+='<td><a href="'$EXP_URL'">Expected</a><div class="md5" title="'$EXP_MD5'">'$EXP_MD5'</div><div class="diff"><wbr></div>'
        # prepare a result cell for each language
        for lang in ${LANGUAGES[@]}; do
            local RESULT_URL="libs/$lang$FILE.json"
            local RESULT_ERR="libs/$lang$FILE.err"
            local RESULT_DIFF="libs/$lang$FILE.diff.txt"
            local ERR_HTML=""
            if [ -s "$RESULT_ERR" ]; then
                # remove the base path from any embedded paths in the error log; we cannot do this in-place portably between GNU and macOS, so we'll create a new file instead
                sed -E -e "s#([ \"])$base_dir/#\1#" -e "s#^$base_dir/##" -e "s# $HOME/# ~/#" "$RESULT_ERR" > "$RESULT_ERR.txt"
                rm -f "$RESULT_ERR"
            fi
            if [ -e "$RESULT_ERR.txt" -a ! -s "$RESULT_URL" ]; then
                # the test program produced one or more errors and did not produce output; mark the whole test in error
                TBODY+='<td class="error"><a href="'$RESULT_ERR.txt'">Error</a><div class="md5"><wbr></div><div class="diff"><wbr></div>'
            else
                if [ -s "$RESULT_ERR.txt" ]; then
                    # The test produced non-fatal errors e.g. warnings; prepare a link to the error information to be included along with the output
                    ERR_HTML='/<a class="error" href="'$RESULT_ERR.txt'">Error</a>'
                else
                    # otherwise delete any empty error files
                    rm -f "$RESULT_ERR"
                fi
                local RESULT_MD5=`md5sum "$RESULT_URL" |cut -d ' ' -f 1`
                if [ "$RESULT_MD5" = "$EXP_MD5" ]; then
                    # the test passed; increment the number of passed tests
                    COUNTS["$lang"]=$((${COUNTS["$lang"]} + 1))
                    TBODY+='<td class="pass"><a href="'$RESULT_URL'">Pass</a>'"$ERR_HTML"'<div class="md5"><wbr></div><div class="diff"><wbr></div>'
                else
                    # the test failed; produce a diff and link to that in addition to the result; if the test is tentative do not treat it is a failure
                    diff -y "$EXP_URL" "$RESULT_URL" > "$RESULT_DIFF"
                    if [ ! "$TENTATIVE" ]; then
                        TBODY+='<td class="fail"><a href="'$RESULT_URL'">Fail</a>'"$ERR_HTML"'<div class="md5" title="'$RESULT_MD5'">'$RESULT_MD5'</div><div class="diff"><a href="'$RESULT_DIFF'">Diff</a></div>'
                    else
                        TBODY+='<td><a href="'$RESULT_URL'">Differ</a>'"$ERR_HTML"'<div class="md5" title="'$RESULT_MD5'">'$RESULT_MD5'</div><div class="diff"><a href="'$RESULT_DIFF'">Diff</a></div>'
                    fi
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
    echo "$THEAD$TBODY"
}

V1TABLE=`make_table test-results/microformats-v1/*/*.json test-results/microformats-mixed/*/*.json`
V2TABLE=`make_table test-results/microformats-v2-unit/*/*.json test-results/microformats-v2/*/*.json`
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
thead {
    white-space: nowrap;
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
<h1>Microformats parser test matrix</h1>
<p><a href="https://github.com/dissolve/mf2-tester">Source</a>
<h2>Basic functionality</h2>
<table>'$V2TABLE'
</table>
<h2>Backwards-compatibility functionality</h2>
<table>'$V1TABLE'
</table>' | sed -E -e 's/(<t(head|body))/\n  \1/g' -e 's/(<tr)/\n    \1/g' -e 's/(<t[dh][ >])/\n      \1/g' > results/index.html
