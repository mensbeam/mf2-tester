#!/bin/bash
function test_one {
    uv run --locked ./languages/python/test-one.py $1
}
