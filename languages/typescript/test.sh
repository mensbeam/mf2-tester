#!/usr/bin/env bash
function test_one {
    NODE_PATH="$3/node_modules" node "$2/test-one.js" "$1"
}
