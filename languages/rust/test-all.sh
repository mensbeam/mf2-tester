#!/bin/bash

for f in vendor/mf2/tests/tests/microformats-*/*/*.html ; 
    do cargo run --locked -q test-one $f |jq -S -f normalize.jq |sed 's/\[\]/{}/g' > `echo $f |sed 's/vendor.mf2.tests.tests/results\/rust/' | sed s/html/json/`;
done;
