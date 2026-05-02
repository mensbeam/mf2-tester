#!/usr/bin/env bash

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null

# define variables for later use
declare -a languages=()
base_dir=`pwd`
report_dir="$base_dir/results"
test_dir="$report_dir/tests"
results_dir="$report_dir/test-results"
src_dir="$base_dir/mf2-tests/tests"
lang_dir="$base_dir/languages"
normalize="$base_dir/normalize.jq"

# if no particular languages were requested, try them all
if [ -z "$1" ]; then
    pushd "$lang_dir" >/dev/null
    declare -a languages=(*)
    popd >/dev/null
else
    declare -a languages=($@)
fi

# make sure docker exists
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not available. Make sure it is installed and the daemon is running."
    exit 1
fi

# fetch the test suite
git submodule update --init --recursive -q

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
        cat "$f" |jq -S -f "$normalize" > "$results_dir$file.json"
    done
fi

# build the Docker images for the requested languages
docker compose build ${languages[@]}

# test the requested libraries
declare -a pids=()
for lang in ${languages[@]}; do
    echo "Testing $lang"
    docker compose run --rm "$lang" &
    pids+=($!)
done
# wait for all containers to finish
for pid in ${pids[@]}; do
    wait "$pid" || true
done

echo "Building Report"
source report.sh
