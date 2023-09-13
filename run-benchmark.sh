#!/usr/bin/env bash

set -euo pipefail

# set env vars
export SF
export SFS=(30 100 300)
export DATA_ROOT=/data/bi-data

# benchmark
cd /data/ldbc_snb_bi/umbra
mkdir -p logs/
for SF in ${SFS[@]}; do
    echo "### Running benchmark on Umbra for SF${SF} started"
    export UMBRA_CSV_DIR=${DATA_ROOT}/bi-sf${SF}-composite-merged-fk/graphs/csv/bi/composite-merged-fk/
    export UMBRA_BUFFERSIZE=400G
    scripts/run-benchmark.sh | tee logs/benchmark-umbra-sf${SF}.log
    echo "### Running benchmark on Umbra for SF${SF} finished"
done

for SF in ${SFS[@]}; do
    echo "### Running scoring script on Umbra for SF${SF} started"
    scripts/score-full.sh umbra ${SF} | tee logs/scoring-umbra-sf${SF}.log
    echo "### Running scoring script on Umbra for SF${SF} finished"
done

# cleanup
rm -f scoring/bi.duckdb

# save zip file
zip -r umbra-results.zip output/ logs/ scoring/
