#!/usr/bin/env bash
function test_one {
    php -d display_errors=stderr "$2/test-one.php" "$1"
}
