#!/bin/bash
src_dir="vendor/mf2/tests/tests"
report_dir="results"
test_dir="$report_dir/tests"
results_dir="results/test-results"
normalize="scripts/normalize.jq"
# if no particular languages were requested, do them all
if [ -z "$1" ]; then
    languages=`ls languages`
else
    languages=$@
fi

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
        cp "$src_dir$file.json" "$results_dir$file.txt"
        cat $f |jq -S -f "$normalize" > "$results_dir$file.json"
    done
fi

# Test the requested libraries
unset -f test_one
for lang in $languages; do
    echo "Preparing $lang"
    source "./languages/$lang/test-all.sh"
    dest_dir="$report_dir/$lang"
    rm -rf "$dest_dir"

    echo "Testing $lang"
    for f in "$test_dir/"microformats-*/*/*.txt ; do
        # compute the output file name
        file=${f#"$test_dir"}
        dest="$dest_dir${file%".txt"}.json"
        # create the output directory if necessary
        mkdir -p `dirname "$dest"`
        # run the test
        test_one $f |jq -S -f "$normalize" >"$dest";
    done
    unset -f test_one
done

echo "Building Report"
./scripts/package.sh
