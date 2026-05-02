#!/usr/bin/env bash
# Based on test.sh, with the build step removed (handled by the Dockerfile instead)
# and the binary path updated to its installed location in the image.
function test_one {
    /usr/local/bin/test-one "$1"
}
