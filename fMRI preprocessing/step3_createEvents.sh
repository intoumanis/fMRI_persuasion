#!/bin/sh
#SBATCH --job-name=createevents
#SBATCH --output=/home/intoumanis/sugar/code/logs/createevents.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/createevents.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
 
module load R
srun Rscript create_events_in_volumes.R

echo "Finished!"