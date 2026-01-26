#!/usr/bin/env bash 

# See ../deps/lib/microformats_tester.ex for the source code to the Elixir test program which is compiled here
MIX_XDG=1 MIX_QUIET=1 mix escript.build

function test_one {
    "$2/test-one" "$1"
}
