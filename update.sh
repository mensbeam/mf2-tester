#!/bin/bash
function check_deps {
    if [ "$1" ]; then
        declare tools=`cat "languages/$1/tools" | tr '\n' ' '`
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

# update the various libraries if requirements are met
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
