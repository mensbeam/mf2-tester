#!/usr/bin/env bash

cargo info -q microformats | grep '^version:' | awk '{print $2}'
