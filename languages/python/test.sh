#!/usr/bin/env bash
function test_one {
    uv run --locked "$2/test-one.py" "$1"
}
