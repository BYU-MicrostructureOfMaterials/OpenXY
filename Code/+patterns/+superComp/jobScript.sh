#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --parsable

module add matlab/r2017b
matlab -nodisplay -nojvm -r "EBSDBatch($SLURM_ARRAY_TASK_ID)"
