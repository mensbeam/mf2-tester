#!/usr/bin/env bash
basetools="awk sed md5sum jq diff git"

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null
base_dir=`pwd`

# define some paths
report_dir="$base_dir/results"
test_dir="$report_dir/tests"
results_dir="$report_dir/test-results"
src_dir="$base_dir/mf2-tests/tests"
libs_dir="$base_dir/libs"
normalize="$base_dir/normalize.jq"

# enumerate the libraries
pushd "$libs_dir" >/dev/null
declare -a LIBS=(*)
popd >/dev/null

function check_deps {
    if [ "$1" ]; then
        declare tools=`cat "$libs_dir/$1/tools"`
    else
        declare tools="$basetools"
    fi
    local -a missing=()
    for tool in $tools; do
        if [ ! `command -v $tool` ]; then
            missing+=($tool)
        fi
    done
    echo "${missing[@]}"
}

function check_base_deps {
    # Check basic dependencies
    local missing=`check_deps`
    if [ "$missing" ]; then
        for tool in $missing; do
            echo "Required tool '$tool' is not installed."
        done
        exit 1
    fi
    # check if Docker is available; this will be used as a fallback if a library's requirements cannot be met by installed software
    HAVE_DOCKER=`docker compose version 2>/dev/null >/dev/null && echo "docker"`
    if [ "$FORCE_DOCKER" ] && [ ! "$HAVE_DOCKER" ]; then
        echo "Docker Compose is not available on the system."
        exit 3
    fi
}

function get_tests {
    # fetch the test suite
    echo "Fetching test suite"
    git submodule update --init --recursive -q
}

function docker_run {
    local LIB=$1
    shift
    # create the report directory if it does not exist; this needs to be created before Docker runs so it is not owned by root
    mkdir -p "$report_dir"
    docker compose --project-directory "$libs_dir/$LIB" run -q --quiet-build --quiet-pull --rm --user "$(id -u):$(id -g)" "$LIB" $@
}

function setup {
    if [ "$#" -gt 0 ]; then
        local LIBS=$@
    fi
    for LIB in ${LIBS[@]}; do
        local missing=`check_deps "$LIB"`
        pushd "$libs_dir/$LIB" >/dev/null
        if [ ! "$missing" ] && [ ! "$FORCE_DOCKER" ]; then
            echo "Setting up $LIB library"
            ./actions setup
        elif [ "$HAVE_DOCKER" ]; then
            docker_run "$LIB" ./do docker-setup "$LIB"
        else
            echo "Skipping set-up of $LIB library (requires: $missing)"
        fi
        popd >/dev/null
    done
}

function update {
    if [ "$#" -gt 0 ]; then
        local LIBS=$@
    fi
    for LIB in ${LIBS[@]}; do
        local missing=`check_deps "$LIB"`
        pushd "$libs_dir/$LIB" >/dev/null
        if [ ! "$missing" ] && [ ! "$FORCE_DOCKER" ]; then
            echo "Updating $LIB library"
            ./actions update
        elif [ "$HAVE_DOCKER" ]; then
            docker_run "$LIB" ./do docker-update $LIB
        else
            echo "Skipping update of $LIB library (requires: $missing)"
        fi
        popd >/dev/null
    done
}

function populate_expectations {
    # if the test input or expected results are missing from the report or are stale, recreate them
    if [ ! -e "$test_dir" ] || [ ! -e "$results_dir" ] || [ -e "$report_dir/stale" ]; then
        echo "Initializing test results"
        rm -rf "$test_dir" "$results_dir" "$report_dir/stale"
        for f in "$src_dir/"microformats-*/*/*.json ; do
            # compute the fixed part of the file name
            file=${f#"$src_dir"}
            file=${file%".json"}
            # create destination directories where necessary
            mkdir -p "$test_dir"`dirname "$file"`
            mkdir -p "$results_dir"`dirname "$file"`
            # copy the input and output files
            cp "$src_dir$file.html" "$test_dir$file.txt"
            cat "$f" | jq -S -f "$normalize" > "$results_dir$file.json"
        done
    fi
}

function build {
    # if no particular libraries were requested, try them all
    if [ -z "$1" ]; then
        local -a requested=(${LIBS[@]})
    else
        local -a requested=($@)
    fi
    # determine whether we use native tools or Docker to run the tests
    local -a native_runs
    local -a docker_runs
    for LIB in ${requested[@]}; do
        if [ ! -e "$libs_dir/$LIB" ]; then
            echo "Skipping $LIB (does not exist)"
        elif [ "$FORCE_DOCKER" ]; then
            docker_runs+=("$LIB")
        else
            local missing=`check_deps $LIB`
            if [ ! "$missing" ]; then
                native_runs+=("$LIB")
            elif [ "$HAVE_DOCKER" ]; then
                docker_runs+=("$LIB")
            else
                echo "Skipping $LIB (needed: $missing)"
            fi
        fi
    done
    # queue up Docker containers; these will run in the background
    local -a pids
    for LIB in ${docker_runs[@]}; do
        docker_run "$LIB" ./do docker-execute "$LIB" &
        pids+=($!)
    done
    # Perform native executions
    for LIB in ${native_runs[@]}; do
        execute $LIB
    done
    # wait for Docker containers to finish
    for pid in ${pids[@]}; do
        wait "$pid" || true
    done
}

function execute {
    local LIB="$1"
    echo "Testing $LIB"
    local dest_dir="$report_dir/libs/$LIB"
    local HAVE_PARALLEL=`command -v parallel`
    rm -rf "$dest_dir"
    mkdir -p "$dest_dir"
    pushd "$libs_dir/$LIB" >/dev/null
    ./actions version >"$dest_dir/version"
    ./actions compile
    local commands=""
    for f in "$test_dir/"microformats-*/*/*.txt ; do
        # compute the output file names
        file=${f#"$test_dir"}
        dest="$dest_dir${file%".txt"}.json"
        err="$dest_dir${file%".txt"}.err"
        # create the output directory if necessary
        mkdir -p `dirname "$dest"`
        # either buffer the test if Parallel is available, or run it now otherwise
        local command="./actions test '$f' 2>'$err' | jq -S -f '$normalize' >'$dest'"
        if [ "$HAVE_PARALLEL" ]; then
            commands+="$command"$'\n'
        else
            eval $command
        fi
    done
    # execute the tests in a batch if using Parallel
    if [ "$HAVE_PARALLEL" ]; then
        parallel <<< "$commands"
    fi
    popd >/dev/null
}

function make_report {
    echo "Building Report"
    V1TABLE=`make_table "$results_dir"/microformats-v1/*/*.json "$results_dir"/microformats-mixed/*/*.json`
    V2TABLE=`make_table "$results_dir"/microformats-v2-unit/*/*.json "$results_dir"/microformats-v2/*/*.json`
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
<p><a href="https://github.com/mensbeam/mf2-tester">Source</a>
<h2>Basic features</h2>
<table>'$V2TABLE'
</table>
<h2>Backwards-compatibility features</h2>
<table>'$V1TABLE'
</table>' | sed -E -e 's/(<t(head|body))/\n  \1/g' -e 's/(<tr)/\n    \1/g' -e 's/(<t[dh][ >])/\n      \1/g' > results/index.html
}

function make_table {
    # get the list of actually tested libraries
    pushd "$report_dir/libs" >/dev/null
    local -a LIBS=(*)
    popd >/dev/null
    # keep track of the number of passed tests for each library
    local -A COUNTS
    for LIB in ${LIBS[@]}; do
        local -i COUNTS["$LIB"]=0
    done
    local -i TOTAL=0
    # Prepare the table body; this consists of one row for each test
    pushd "$report_dir" >/dev/null
    local TBODY='<tbody>'
    for f in $@ ; do
        # compute the fixed part of the file name
        local FILE=${f#"$results_dir"}
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
        # prepare a result cell for each library
        for LIB in ${LIBS[@]}; do
            local RESULT_URL="libs/$LIB$FILE.json"
            local RESULT_ERR="libs/$LIB$FILE.err"
            local RESULT_DIFF="libs/$LIB$FILE.diff.txt"
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
                    COUNTS["$LIB"]=$((${COUNTS["$LIB"]} + 1))
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
    popd >/dev/null

    # next prepare the table header
    THEAD='<thead>'
    # the first row contains library names and versions
    THEAD+='<tr><th rowspan="2">Test<th><a href="https://github.com/microformats/tests">Test Suite</a><div class="version">'$TEST_SUITE_VERSION'</div>'
    for LIB in ${LIBS[@]}; do 
        NAME=`cat "$libs_dir/${LIB}/label"`
        LINK=`cat "$libs_dir/${LIB}/link"`
        VERSION=`cat "$report_dir/libs/${LIB}/version"`
        THEAD+='<th><a href="'$LINK'">'$NAME'</a><div class="version">'$VERSION'</div>'
    done
    # the second row contains test counts
    THEAD+='<tr><td>'$TOTAL' tests'
    for LIB in ${LIBS[@]}; do 
        THEAD+='<td>'${COUNTS["$LIB"]}' passed'
    done
    echo "$THEAD$TBODY"
}


# Check if the version of Bash is ancient; this is typically the case on macOS
if [ `echo "$BASH_VERSION" | sed -Ee 's/^([0-9]+).*/\1/'` -lt 4 ]; then
    echo 'Bash 4.0 or later is required for these scripts to work correctly. Please'
    echo 'update your version of Bash. If you are using macOS this can be done with'
    echo 'Homebrew by issuing the following command:'
    echo ''
    echo '    brew install bash'
    echo ''
    exit 2
fi

if [ "$1" = "docker-execute" ]; then
    # this is used internally by Docker and should not be used directly
    execute "$2"
elif [ "$1" = "docker-setup" ]; then
    # this is used internally by Docker and should not be used directly
    setup "$2"
elif [ "$1" = "docker-update" ]; then
    # this is used internally by Docker and should not be used directly
    update "$2"
elif [ "$1" = "docker-debug" ]; then
    docker_run "$2"
elif [ "$1" = "build" ] || [ "$1" = "build-native" ] || [ "$1" = "build-docker" ]; then
    if [ "$1" = "build-docker" ]; then
        FORCE_DOCKER=1
    fi
    check_base_deps
    populate_expectations
    if [ "$1" = "build-native" ]; then
        HAVE_DOCKER=""
    fi
    shift
    build $@
    make_report
elif [ "$1" = "update" ]; then
    if [ "$2" = "docker" ]; then
        FORCE_DOCKER=1
    fi
    check_base_deps
    get_tests
    if [ "$2" = "native" ]; then
        HAVE_DOCKER=""
    fi
    update
elif [ "$1" = "setup" ]; then
    if [ "$2" = "docker" ]; then
        FORCE_DOCKER=1
    fi
    check_base_deps
    get_tests
    if [ "$2" = "native" ]; then
        HAVE_DOCKER=""
    fi
    setup
elif [ "$1" = "report" ]; then
    make_report
else
    echo "Usage:"
    echo "./do setup [docker|native]"
    echo "./do update [docker|native]"
    echo "./do build [<library>...]"
    echo "./do build-docker [<library>...]"
    echo "./do build-native [<library>...]"
fi