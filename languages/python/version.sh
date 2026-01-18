#!/bin/bash
uv export -q | grep ^mf2py== | cut -d ' ' -f 1 | cut -d '=' -f 3