#!/bin/bash
echo "Removing any previous data"
./scripts/destroy.sh
echo "Initializing language directories"
./scripts/initialize.sh

unset -f test_one

for lang in `ls languages`; do
    echo "Testing $lang"
    source "./languages/$lang/test-all.sh"

    for f in vendor/mf2/tests/tests/microformats-*/*/*.html ; do
        test_one $f |jq -S -f normalize.jq > `echo $f |sed 's/vendor.mf2.tests.tests/results\/'$lang'/' | sed s/html/json/`;
    done
    unset -f test_one
done

echo "Building Report"
./scripts/package.sh
