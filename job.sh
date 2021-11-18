#!/usr/bin/env bash
#$ -l h_rt=8:0:0,mfree=8G
#$ -N snakemake
#$ -cwd
#$ -o logs/snakemake.log
#$ -e logs/snakemake.log
set -euo pipefail
snakemake --profile ./profiles/sge --use-conda --cores all
