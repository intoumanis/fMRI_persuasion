
import argparse
import sys
import subprocess
import os
from nilearn import image as img
import pandas as pd
import glob

# Main function
if __name__ == '__main__':

	usage = """post_fmriprep.py <path_to_BOLD.nii.gz> <path_to_confound.tsv> <list_of_confounds_to_regress>
	e.g. post_fmriprep.py /m/nbe/scratch/braindata/eglerean/code/triton/fmripreptest/ds000030_derivatives/fmriprep/sub-10159/func/sub-10159_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz  /m/nbe/scratch/braindata/eglerean/code/triton/fmripreptest/ds000030_derivatives/fmriprep/sub-10159/func/sub-10159_task-rest_desc-confounds_regressors.tsv csf,csf_derivative1,csf_power2,csf_derivative1_power2,white_matter,white_matter_derivative1,white_matter_power2,white_matter_derivative1_power2,global_signal,global_signal_derivative1,global_signal_power2,global_signal_derivative1_power2,std_dvars,dvars,framewise_displacement"""
	parser = argparse.ArgumentParser(description='input params')
	parser.add_argument('niifile', metavar='niifile', type=str, nargs=1, help='path to BOLD.nii.gz')
	parser.add_argument('confounds', metavar='confounds', type=str, nargs=1, help='path to confounds.tsv')
	args = parser.parse_args()

	niifile=args.niifile[0]
	confounds=args.confounds[0]

	###### Data cleaning

	# Read confounds -file (Delimiter is \t --> tsv is a tab-separated spreadsheet)
	confound_df = pd.read_csv(confounds, delimiter='\t')

	# select confound variables: (Check Parkes et al. 2018)
	# first select variables that are marked as motion_outliers
	# criteria in this study FD > 0.5 and DVARS > 2
	confound_outlier = confound_df.columns.values.tolist()
	confound_outlier = [k for k in confound_outlier if 'motion_outlier' in k]

	# select other confound variables, uncomment below for removing also global signal
	# confound_vars = ['framewise_displacement', 'csf', 'csf_derivative1', 'csf_power2', 'csf_derivative1_power2', 'white_matter', 'white_matter_derivative1', 'white_matter_power2', 'white_matter_derivative1_power2', 'global_signal', 'global_signal_derivative1', 'global_signal_derivative1_power2', 'global_signal_power2', 'trans_x', 'trans_x_derivative1', 'trans_x_derivative1_power2', 'trans_x_power2', 'trans_y', 'trans_y_derivative1', 'trans_y_power2', 'trans_y_derivative1_power2', 'trans_z', 'trans_z_derivative1', 'trans_z_power2', 'trans_z_derivative1_power2', 'rot_x', 'rot_x_derivative1', 'rot_x_power2', 'rot_x_derivative1_power2', 'rot_y', 'rot_y_derivative1', 'rot_y_power2', 'rot_y_derivative1_power2', 'rot_z', 'rot_z_derivative1', 'rot_z_power2', 'rot_z_derivative1_power2']
	confound_vars = ['csf', 'csf_derivative1', 'csf_power2', 'csf_derivative1_power2', 'white_matter', 'white_matter_derivative1', 'white_matter_power2', 'white_matter_derivative1_power2', 'trans_x', 'trans_x_derivative1','trans_x_derivative1_power2', 'trans_x_power2', 'trans_y', 'trans_y_derivative1', 'trans_y_power2', 'trans_y_derivative1_power2', 'trans_z', 'trans_z_derivative1','trans_z_power2', 'trans_z_derivative1_power2', 'rot_x', 'rot_x_derivative1', 'rot_x_power2', 'rot_x_derivative1_power2', 'rot_y', 'rot_y_derivative1', 'rot_y_power2','rot_y_derivative1_power2', 'rot_z', 'rot_z_derivative1', 'rot_z_power2', 'rot_z_derivative1_power2']

	confound_allvars = confound_vars + confound_outlier
	confound_df = confound_df[confound_allvars]
	confound_df.fillna(0, inplace=True) #Replace Nan with value 0

	# load functional image
	func_img = img.load_img(niifile)

	# Change confounds to matrix (confirm matrix with confounds_matrix.shape)
	confounds_matrix = confound_df.values

	# Define high_pass and low_pass values
	high_pass = 0.008
	low_pass = 0.08

	# Clean
	clean_img = img.clean_img(func_img, confounds=confounds_matrix, detrend=True, standardize=True, low_pass=None, high_pass=None, t_r=2, ensure_finite=True )

	# Smooth
	# clean_smooth = img.smooth_img(clean_img, fwhm=6)


	# Save to nii.gz
	clean_file = 'Aggressive_cleaned_' + niifile
	clean_img.to_filename(clean_file)