#!/usr/bin/env bash
uv export -q --no-cache | grep ^mf2py== | cut -d ' ' -f 1 | cut -d '=' -f 3