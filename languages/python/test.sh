#!/usr/bin/env bash
function test_one {
    uv run --locked --no-sync --no-cache "$2/test-one.py" "$1"
}
