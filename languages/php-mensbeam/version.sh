#!/bin/bash
composer show  |grep 'mensbeam/microformats' |sed 's/\ \+/ /g' |cut -d ' ' -f 2
