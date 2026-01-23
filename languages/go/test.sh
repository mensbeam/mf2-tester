#!/bin/bash
rm test-one 2>/dev/null
go build -mod=mod -o "$here/test-one" "$here/test-one.go"

function test_one {
    "$2/test-one" "$1"
}
