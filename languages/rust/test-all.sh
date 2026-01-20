#!/bin/bash
function test_one {
    cargo run --locked -q test-one $1
}