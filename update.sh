#!/bin/bash

echo "Updating PHP library (and test suite)"
composer update -q

echo "Updating JavaScript and TypeScript libraries"
npm update --silent

echo "Updating Rust library"
cargo update -q
cargo build -q

echo "Updating Ruby library"
bundle update --all --quiet

echo "Updating Python library"
uv lock --upgrade -q

echo "Updating Go library"
go get -u ./... >/dev/null