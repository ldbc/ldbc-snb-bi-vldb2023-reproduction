#!/usr/bin/env bash

set -euo pipefail

# set env vars
export SF
export SFS=(30 100 300)
export DATA_ROOT=/data/bi-data

mkdir -p ${DATA_ROOT}

echo "### Fetching Umbra's Docker image started"
cd /data/ldbc_snb_bi/umbra
export UMBRA_URL_PREFIX=https://pub-383410a98aef4cb686f0c7601eddd25f.r2.dev/bi-pre-audit/umbra-docker-
. scripts/vars.sh
curl https://pub-383410a98aef4cb686f0c7601eddd25f.r2.dev/bi-pre-audit/umbra-docker-${UMBRA_VERSION}.tar.gz | docker load
echo "### Fetching Umbra's Docker image finished"

# get data sets and factors
for SF in ${SFS[@]}; do
    cd ${DATA_ROOT}
    
    echo "### Downloading data set for SF${SF} started"
    wget https://pub-383410a98aef4cb686f0c7601eddd25f.r2.dev/bi-pre-audit/bi-sf${SF}-composite-merged-fk.tar.zst
    tar xf bi-sf${SF}-composite-merged-fk.tar.zst
    rm bi-sf${SF}-composite-merged-fk.tar.zst
    echo "### Downloading data set for SF${SF} finished"

    echo "### Downloading factors for SF${SF} started"
    wget https://pub-383410a98aef4cb686f0c7601eddd25f.r2.dev/bi-pre-audit/factors/factors-sf${SF}.tar.zst
    tar xf factors-sf${SF}.tar.zst
    rm factors-sf${SF}.tar.zst
    echo "### Downloading factors for SF${SF} finished"

    echo "### Generating parameters for SF${SF} started"
    cd /data/ldbc_snb_bi/paramgen
    rm -rf scratch/factors
    mkdir -p scratch/factors
    cp -r ${DATA_ROOT}/factors-sf${SF}/parquet/raw/composite-merged-fk/* scratch/factors/
    scripts/paramgen.sh
    echo "### Generating parameters for SF${SF} finished"
done
