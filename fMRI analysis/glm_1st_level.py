print('Starting...', flush=True)
import os
from nilearn.glm.first_level.design_matrix import make_first_level_design_matrix
from nilearn.glm.first_level import first_level_from_bids
from nilearn import plotting
from nilearn import image
import numpy as np

data_dir = '/home/intoumanis/sugar/data_bids'
task_label = 'narrative'
space_label = "MNI152NLin6Asym"
derivatives_folder = '../derivatives'

Nsubjects = 50

for subject in range(50,51): #range(Nsubjects):
    
    print(subject, flush=True)

    subject = str(subject)
    print(subject, flush=True)

    (
        models,
        models_run_imgs,
        models_events,
        models_confounds,
    ) = first_level_from_bids(
        dataset_path = data_dir,
        sub_labels=subject,
        task_label = task_label,
        space_label = space_label,
        derivatives_folder = derivatives_folder,
        img_filters=[("desc", "preproc")],
        smoothing_fwhm=6,
        t_r = 2,
        slice_time_ref = 0.5 # when we ran fMRIprep we used 1s as a reference for the slice timing correction, which is TR/2 hence the 0.5
    )
        
    model, imgs, events, confounds = (
    models[0],
    models_run_imgs[0][0],
    models_events[0][0],
    models_confounds[0][0],
    )
    subject = f"sub-{model.subject_label}"
    model.minimize_memory = False  # override default
    
    events.onset = events.onset*2 # the events are in volumes - we convert to seconds

    condition = []
    for i in range(events.shape[0]):
        if events['trial_type'][i] == 'SugarContaining' and events['block'][i] == 1:
            condition.append('SugarContaining1')
        elif events['trial_type'][i] == 'SugarContaining' and events['block'][i] == 2:
            condition.append('SugarContaining2')
        elif events['trial_type'][i] == 'SugarFree' and events['block'][i] == 1:
            condition.append('SugarFree1')
        elif events['trial_type'][i] == 'SugarFree' and events['block'][i] == 2:
            condition.append('SugarFree2')
        elif events['trial_type'][i] == 'NonEdible' and events['block'][i] == 1:
            condition.append('NonEdible1')
        elif events['trial_type'][i] == 'NonEdible' and events['block'][i] == 2:
            condition.append('NonEdible2')
        else:
            condition.append('Narrative')

    
    events['trial_type'] = condition

    # Calculate scanning duration
    this_image = image.load_img(imgs)
    this_image_data = image.get_data(this_image)
    scanning_duration = this_image_data.shape[3]*2 # we multiply by 2 so that it is in seconds
    del this_image, this_image_data

    confounds = confounds[["trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z", "csf", "white_matter", "framewise_displacement"]].fillna(0) # for the first value of the FD

    x = make_first_level_design_matrix(np.linspace(0, scanning_duration, int(scanning_duration/2)), events, add_regs = confounds)

    model.fit(imgs, design_matrices = x)

    # Contrasts
    try:
        b_map_sugar = model.compute_contrast("SugarContaining2 - SugarContaining1", output_type = "all")
        b_map_sugar['effect_size'].to_filename(os.path.join('/home/intoumanis/sugar/results/GLM', subject + '_sugar_beta_map.nii.gz'))
    
        b_map_sugarfree = model.compute_contrast("SugarFree2 - SugarFree1", output_type = "all")
        b_map_sugarfree['effect_size'].to_filename(os.path.join('/home/intoumanis/sugar/results/GLM/', subject + '_sugarfree_beta_map.nii.gz'))

        b_map_nonedible = model.compute_contrast("NonEdible2 - NonEdible1", output_type = "all")
        b_map_nonedible['effect_size'].to_filename(os.path.join('/home/intoumanis/sugar/results/GLM/', subject + '_nonedible_beta_map.nii.gz'))
        
    except np.linalg.LinAlgError:
        continue









