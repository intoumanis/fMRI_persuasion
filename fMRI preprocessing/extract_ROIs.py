import os
import glob
import csv
from nltools.data import Brain_Data
from nltools.mask import expand_mask
import pandas as pd

mask = Brain_Data('/home/intoumanis/sugar/code/other/AAL3v1.nii')
mask_x = expand_mask(mask)

# Read all the cropped nifti files, extract the avg BOLD within each ROI and save it in a csv file whose name indicates the subject
data_dir = '/home/intoumanis/sugar/data_ISC'
file_list = glob.glob(os.path.join(data_dir, 'sub*.nii'))

# If you want only certain subjects you can specify it here:
files = [x for x in file_list if 'sub-50' not in x]

for f in files:
    sub = os.path.basename(f).split('.')[0]
    data = Brain_Data(f)
    roi = data.extract_roi(mask)
    file_to_be_saved = os.path.join(os.path.dirname(f), f"{sub}_AAL.csv")
    pd.DataFrame(roi.T).to_csv(file_to_be_saved, index=False)
    print('Finished for ' + sub + ' \n')