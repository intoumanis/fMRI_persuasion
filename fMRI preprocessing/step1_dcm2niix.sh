#!/bin/sh
#SBATCH --job-name=dcm2nii
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=02:00:00
#SBATCH --output=/home/intoumanis/sugar/code/logs/dcm2nifti.out
#SBATCH --error=/home/intoumanis/sugar/code/logs/dcm2nifti.err


# The user changes only the variable "participant", which corresponds to the folder where the raw data are
participants="sub-50"

for participant in $participants; do

	### Anatomical images (T1w)

	input_anat=$"/home/intoumanis/sugar/data_raw/$participant/DICOM/PA000000/ST000000/SE000005"
	output_anat=$"/home/intoumanis/sugar/data_bids/$participant/anat"
	mkdir -p $output_anat
	filename=$participant"_T1w"

	./dcm2niix/build/bin/dcm2niix -z y -b y -f $filename -o $output_anat $input_anat



	### Functional images

	input_func=$"/home/intoumanis/sugar/data_raw/$participant/DICOM/PA000000/ST000000/SE000006"
	output_func=$"/home/intoumanis/sugar/data_bids/$participant/func"
	mkdir -p $output_func

	filename=$participant"_task-narrative_bold"

	./dcm2niix/build/bin/dcm2niix -z y -b y -f $filename -o $output_func $input_func

done