#!/usr/bin/env bash

LANG_DIR="/app/languages/${LANG_NAME}"
DEST_DIR="/app/results/libs/${LANG_NAME}"

cd /app/deps

if [ -f "${LANG_DIR}/docker-test.sh" ]; then
    source "${LANG_DIR}/docker-test.sh"
else
    source "${LANG_DIR}/test.sh"
fi

rm -rf "${DEST_DIR}"

for f in /app/results/tests/microformats-*/*/*.txt; do
    file="${f#"/app/results/tests"}"
    dest="${DEST_DIR}${file%.txt}.json"
    err="${DEST_DIR}${file%.txt}.err"
    mkdir -p "$(dirname "${dest}")"
    test_one "${f}" "${LANG_DIR}" "/app/deps" 2>"${err}" \
        | jq -S -f /app/normalize.jq > "${dest}" || true
done

# capture the library version for use by report.sh
bash "${LANG_DIR}/version.sh" > "${DEST_DIR}/version"
