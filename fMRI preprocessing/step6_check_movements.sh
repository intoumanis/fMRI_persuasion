#!/bin/bash
#SBATCH --job-name=movements # Task name
#SBATCH --error=/home/intoumanis/sugar/code/logs/movements.err # Error output file
#SBATCH --output=/home/intoumanis/sugar/code/logs/movements.out # Output file
 
module load R/v4.0.3 # Load R module
srun Rscript check_movements.R # Run Rscript with file test.r