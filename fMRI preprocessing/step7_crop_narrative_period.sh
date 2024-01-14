#!/bin/bash
#SBATCH --job-name=crop_narrative
#SBATCH --time=10:00:00
#SBATCH --output=/home/intoumanis/sugar/code/logs/crop_narrative-%A-%a.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/crop_narrative-%A-%a.err
#SBATCH --array=31-49


module load Python/Anaconda_v11.2021
source activate expert_power

sub=$SLURM_ARRAY_TASK_ID

echo "Cropping data of subject sub-$sub..."

input_nii=$"/home/intoumanis/sugar/derivatives/sub-$sub/func/Aggressive_cleaned_sub-${sub}_task-narrative_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz"
output_nii=$"/home/intoumanis/sugar/data_ISC/sub-${sub}.nii"
events_file=$"/home/intoumanis/sugar/data_bids/sub-$sub/func/sub-${sub}_task-narrative_events.tsv"

python /home/intoumanis/sugar/code/crop.py $input_nii $output_nii $events_file

echo "Data of subject $sub were cropped successfully!"