
import argparse
import sys
import os
import glob
import numpy as np
import pandas as pd
from nilearn import image as img
import nibabel

# Usage: crop.py <input nifti file to be cropped> <filename to save the cropped data> <events file with info necessary for cropping>

# Main function
if __name__ == '__main__':

	input_nii = sys.argv[1]
	output_nii = sys.argv[2]
	events_file = sys.argv[3]

	# Load the nifti file
	whole_img = img.load_img(input_nii)
	data = img.get_data(whole_img)

	# Load the events file
	events = pd.read_csv(events_file, sep = '\t')
	onset = events.onset[events.trial_type.tolist().index("narrative")] + 4 # We remove the first 10 seconds, i.e., 5 TRs
	offset = onset + 207 # we also remove from the end

	# Crop the data
	cropped_data = data[:,:,:,onset:offset]
	cropped_img = img.new_img_like(whole_img, cropped_data)
	# test = img.get_data(cropped_img)

	# Save the cropped data
	cropped_img.to_filename(output_nii)