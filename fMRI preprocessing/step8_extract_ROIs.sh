#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --output=/home/intoumanis/sugar/code/logs/ROI.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/ROI.err

module load Python/Anaconda_v11.2021
source activate expert_power

srun python extract_ROIs.py