#!/usr/bin/env bash
# Based on test.sh, with cargo run replaced by a direct call to the binary
# pre-built by the Dockerfile.
function test_one {
    /app/deps/target/release/test-one test-one "$1"
}
