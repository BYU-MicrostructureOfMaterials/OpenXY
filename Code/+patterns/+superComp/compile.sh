#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=4096MB
#SBATCH --time=01:00:00


module add matlab/r2017b
path_name="`pwd`/$1"
echo $path_name
matlab -nodisplay -nojvm -r "compileOutput('$path_name')"
