#!/usr/bin/env bash
#$ -l h_rt=8:0:0,mfree=8G
#$ -N snakemake
#$ -cwd
#$ -e logs/snakemake.log
#$ -o logs/snakemake.log
set -euo pipefail
conda activate ./envs
snakemake --profile profiles/sge
