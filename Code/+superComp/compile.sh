#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=2048MB
#SBATCH --time=00:05:00


module add matlab/r2017b
path_name="`pwd`/$1"
echo $path_name
matlab -nodisplay -nojvm -r "compileOutput('$path_name')"
