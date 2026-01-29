#!/usr/bin/env bash

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null
base_dir=`pwd`

function check_deps {
    if [ "$1" ]; then
        declare tools=`cat "$base_dir/languages/$1/tools"`
    else
        return
    fi
    declare -a missing=()
    for tool in $tools; do
        if [ ! `command -v $tool` ]; then
            missing+=($tool)
        fi
    done
    echo "${missing[@]}"
}


echo "Updating test suite and invalidating report"
git submodule update --init --recursive --remote -q
touch "$base_dir/results/stale"

# change to the directory where the package registry files are
pushd "$base_dir/deps" >/dev/null

# update the various libraries if requirements are met
missing=`check_deps elixir`
if [ ! "$missing" ]; then
    echo "Updating Elixir library"
    MIX_QUIET=1 MIX_XDG=1 mix deps.update --all
else
    echo "Skipping update of Elixir library (requires: $missing)"
fi

missing=`check_deps go`
if [ ! "$missing" ]; then
    echo "Updating Go library"
    go get -u ./... >/dev/null
else
    echo "Skipping update of Go library (requires: $missing)"
fi

missing=`check_deps node`
if [ ! "$missing" ]; then
    echo "Updating JavaScript and TypeScript libraries"
    npm update --silent
else
    echo "Skipping update of JavaScript and TypeScript libraries (requires: $missing)"
fi

missing=`check_deps perl`
if [ ! "$missing" ]; then
    echo "Updating Perl library"
    carton update >/dev/null
else
    echo "Skipping update of Perl library (requires: $missing)"
fi

missing=`check_deps php`
if [ ! "$missing" ]; then
    echo "Updating PHP library"
    composer update -q
else
    echo "Skipping update of PHP library (requires: $missing)"
fi

missing=`check_deps python`
if [ ! "$missing" ]; then
    echo "Updating Python library"
    uv lock --upgrade -q
    uv sync -q
else
    echo "Skipping update of Python library (requires: $missing)"
fi

missing=`check_deps ruby`
if [ ! "$missing" ]; then
    echo "Updating Ruby library"
    bundle update --all --quiet
else
    echo "Skipping update of Ruby library (requires: $missing)"
fi

missing=`check_deps rust`
if [ ! "$missing" ]; then
    echo "Updating Rust library"
    cargo update -q
    cargo build -q
else
    echo "Skipping update of Rust library (requires: $missing)"
fi
