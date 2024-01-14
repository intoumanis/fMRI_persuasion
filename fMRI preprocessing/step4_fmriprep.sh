#!/bin/sh
#SBATCH --job-name=fmriprep
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=04-00
#SBATCH --output=/home/intoumanis/sugar/code/logs/fmriprep_%A_%a.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/fmriprep_%A_%a.err
#SBATCH --array=50

module load singularity/3.2.0

cd /home/intoumanis/sugar/

INPUT_DIR=/home/intoumanis/sugar/data_bids/
OUTPUT_DIR=/home/intoumanis/sugar/derivatives/
WORKING_DIR=/home/intoumanis/sugar/temp

singularity run /opt/software/fmriprep/v22.0.2/fmriprep.simg $INPUT_DIR $OUTPUT_DIR -w $WORKING_DIR participant --participant-label 'sub-'$SLURM_ARRAY_TASK_ID --use-aroma --output-spaces MNI152NLin6Asym:res-2 --mem=32GB --fs-no-reconall --fs-license-file /home/intoumanis/taiwan/license.txt