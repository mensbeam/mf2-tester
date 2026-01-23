#!/bin/bash
basetools="md5sum jq diff git"

# make sure we're in the correct directory
pushd `dirname "$0"` >/dev/null
base_dir=`pwd`

function check_deps {
    if [ "$1" ]; then
        declare tools=`cat "$base_dir/languages/$1/tools"`
    else
        declare tools="$basetools"
    fi
    declare -a missing=()
    for tool in $tools; do
        if [ ! `command -v $tool` ]; then
            missing+=($tool)
        fi
    done
    echo "${missing[@]}"
}

# Check basic dependencies
missing=`check_deps`
if [ "$missing" ]; then
    for tool in $missing; do
        echo "Required tool '$tool' is not installed."
    done
    exit 1
fi

echo "Fetching test suite"
git submodule update --init --recursive -q

# change to the directory where the package registry files are
pushd "$base_dir/deps" >/dev/null

# install the various libraries if requirements are met
missing=`check_deps go`
if [ ! "$missing" ]; then
    echo "Installing Go library"
    go get ./... >/dev/null
else
    echo "Skipping installation of Go library (requires: $missing)"
fi

missing=`check_deps node`
if [ ! "$missing" ]; then
    echo "Installing JavaScript and TypeScript libraries"
    npm install --silent
else
    echo "Skipping installation of JavaScript and TypeScript libraries (requires: $missing)"
fi

missing=`check_deps php`
if [ ! "$missing" ]; then
    echo "Installing PHP library"
    composer install -q
else
    echo "Skipping installation of PHP library (requires: $missing)"
fi

missing=`check_deps python`
if [ ! "$missing" ]; then
    echo "Installing Python library"
    uv sync --locked -q
else
    echo "Skipping installation of Python library (requires: $missing)"
fi

missing=`check_deps ruby`
if [ ! "$missing" ]; then
    echo "Installing Ruby library"
    bundle install --quiet
else
    echo "Skipping installation of Ruby library (requires: $missing)"
fi

missing=`check_deps rust`
if [ ! "$missing" ]; then
    echo "Installing Rust library"
    cargo fetch --locked -q
    cargo build --locked -q
else
    echo "Skipping installation of Rust library (requires: $missing)"
fi
