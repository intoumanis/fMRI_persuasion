#!/bin/bash
#SBATCH --time=05:00:00
#SBATCH --output=/home/intoumanis/sugar/code/logs/post_processing_subject-%A-%a.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/post_processing_subject-%A-%a.err
#SBATCH --array=32,34,36-38,43


module load Python/Anaconda_v11.2021
source activate expert_power

sub=$SLURM_ARRAY_TASK_ID

echo "Postprocessing subject $sub..."

cd /home/intoumanis/sugar/derivatives/sub-$sub/func

Niifile="sub-${sub}_task-narrative_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz"
Confounds=$(ls | grep confounds | grep tsv)

python /home/intoumanis/sugar/code/post_fmriprep.py $Niifile $Confounds

echo "Subject $sub was preprocessed successfully!"