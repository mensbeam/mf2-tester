#!/bin/bash
missing=0
tools="md5sum jq diff composer php go cargo npm node uv bundle"

# Check shell dependencies
for tool in $tools; do
    if [ ! $(command -v $tool) ]; then
        echo "Required tool '$tool' is not installed."
        missing=1
    fi
done
if [ $missing -gt 0 ]; then
    exit
fi

echo "Installing PHP library (and test suite)"
composer install -q

echo "Installing JavaScript and TypeScript libraries"
npm install --silent

echo "Installing Rust library"
cargo fetch -q
cargo build -q

echo "Installing Ruby library"
bundle install --quiet

echo "Installing Python library"
uv sync -q