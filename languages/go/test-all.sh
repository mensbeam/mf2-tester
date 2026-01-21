#!/bin/bash
rm test-one 2>/dev/null
go build -mod=mod -o ./languages/go/test-one ./languages/go/test-one.go

function test_one {
    ./languages/go/test-one "$1"
}
