#!/bin/bash

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null

# define variables for later use
declare -a languages=()
base_dir=`pwd`
report_dir="$base_dir/results"
test_dir="$report_dir/tests"
results_dir="$report_dir/test-results"
src_dir="$base_dir/deps/vendor/mf2/tests/tests"
lang_dir="$base_dir/languages"
normalize="$base_dir/scripts/normalize.jq"

# if no particular languages were requested, try them all
if [ -z "$1" ]; then
    pushd "$lang_dir" >/dev/null
    declare -a requested=(*)
    popd >/dev/null
else
    declare -a requested=($@)
fi
# however, skip the ones for which we're missing dependencies
for lang in ${requested[@]}; do
    declare -a missing=()
    for tool in `cat "$lang_dir/$lang/tools" | tr '\n' ' '`; do
        if [ ! `command -v $tool` ]; then
            missing+=($tool)
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Skipping $lang (needed: ${missing[@]})"
    else
        languages+=("$lang")
    fi
done

# if the test input or expected results are missing from the report, create them
if [ ! -e "$test_dir" ] || [ ! -e "$results_dir" ]; then
    echo "Initializing test results"
    for f in "$src_dir/"microformats-*/*/*.json ; do
        # compute the fixed part of the file name
        file=${f#"$src_dir"}
        file=${file%".json"}
        # create destination directories where necessary
        mkdir -p "$test_dir"`dirname "$file"`
        mkdir -p "$results_dir"`dirname "$file"`
        # copy the input and output files
        cp "$src_dir$file.html" "$test_dir$file.txt"
        cat "$f" |jq -S -f "$normalize" > "$results_dir$file.json"
    done
fi

# check if GNU Parallel is available
HAVE_PARALLEL=""
if [ $(command -v parallel) ]; then
    HAVE_PARALLEL=1
fi

# change the working directory to where all the package registry files are
pushd "$base_dir/deps" >/dev/null

# test the requested libraries
unset -f test_one
for lang in ${languages[@]}; do
    # prepare the tests
    echo "Testing $lang"
    here="$lang_dir/$lang"
    source "$here/test-all.sh"
    dest_dir="$report_dir/libs/$lang"
    rm -rf "$dest_dir"

    commands=""
    for f in "$test_dir/"microformats-*/*/*.txt ; do
        # compute the output file names
        file=${f#"$test_dir"}
        dest="$dest_dir${file%".txt"}.json"
        err="$dest_dir${file%".txt"}.err.txt"
        # create the output directory if necessary
        mkdir -p `dirname "$dest"`
        # either buffer the test if Parallel is available, or run it now otherwise
        command="test_one \"$f\" \"$here\" \"`pwd`\" 2>\"$err\" |jq -S -f \"$normalize\" >\"$dest\""
        if [ $HAVE_PARALLEL ]; then
            commands+="$command"$'\n'
        else
            eval $command
        fi
    done
    # execute the tests in a batch if using Parallel
    if [ $HAVE_PARALLEL ]; then
        export -f test_one
        parallel <<< "$commands"
    fi
    unset -f test_one
done

# restore the working directory
popd >/dev/null

echo "Building Report"
./scripts/package.sh
