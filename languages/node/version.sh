#!/usr/bin/env bash
npm ls -json | jq -r '.dependencies["microformat-node"].version | .'
