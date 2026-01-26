#!/usr/bin/env bash 
function test_one {
    MIX_XDG=1 mix run "$2/test-one.exs" "$1"
}
