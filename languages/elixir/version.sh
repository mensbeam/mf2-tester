#!/usr/bin/bash
MIX_XDG=1 mix deps | grep '(microformats2)' | sed 's/^ *//' | cut -d ' ' -f 3
