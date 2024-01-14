#!/bin/bash
#SBATCH --time=2-01:00:00
#SBATCH --output=/home/intoumanis/sugar/code/logs/GLM1.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/GLM1.err

module load Python/Anaconda_v11.2021
source activate expert_power

srun python glm_1st_level.py