#!/usr/bin/env bash

# ============================================================
# Generate the NINJAX 5k GW+KN dataset.
#
# WARNING:
#   This is a GPU generation job.
#
#   Resources:
#     - CUDA-capable GPU
#     - ~2 GB or more system RAM
#     - ~1 GB free disk space
#
#   Ensure that the above resources are available before running.
# ============================================================

# Fail fast on command errors, wrong variables, or general failures.
set -euo pipefail

N_EVENTS=5000
BATCH_SIZE=5000
SEED=42

OUTDIR="GWKN_source_5k"

ninjax-generate \
    --n-samples "$N_EVENTS" \
    --batch-size "$BATCH_SIZE" \
    --output-format hdf5 \
    --eos GWKN_source_5k/data/eos/ALF2.dat \
    --prior-file GWKN_source_5k/data/prior.toml \
    --fixed-params GWKN_source_5k/data/fixed_params.json \
    --gw.mode polarizations \
    --gw.f-min 20 \
    --gw.f-max 1024 \
    --gw.delta-f 0.25 \
    --gw.f-ref 20 \
    --em.model-name Bu2026_MLP \
    --em.filters ztfg ztfr ztfi \
    --seed "$SEED" \
    --outdir "$OUTDIR"