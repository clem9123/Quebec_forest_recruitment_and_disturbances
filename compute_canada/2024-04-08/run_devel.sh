#!/bin/bash
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-8

cd $SLURM_SUBMIT_DIR
Rscript launch.R $SLURM_ARRAY_TASK_ID
