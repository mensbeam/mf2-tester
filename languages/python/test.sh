#!/usr/bin/env bash
function test_one {
    uv run --locked --no-sync "$2/test-one.py" "$1"
}
