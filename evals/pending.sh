#!/bin/sh
# usage: pending.sh RUN_DIR  -> prints case ids without a result file yet
for p in "$1"/prompts/*.txt; do id=$(basename "$p" .txt); [ -s "$1/results/$id.txt" ] || echo "$id"; done
