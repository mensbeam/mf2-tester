#!/usr/bin/env bash
function test_one {
    carton exec "$2/test-one.pl" "$1"
}