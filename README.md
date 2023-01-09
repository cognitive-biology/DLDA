# Direct linear discriminant analysis (DLDA)
Here we provide a set of [MATLAB](https://mathworks.com/products/matlab) based scripts to perform direct linear discriminant analysis on fMRI data.


##Citing##
Please use the following paper to cite the toolbox:

Kakaei,E. & Braun, J. (2023) -  Gradual change of cortical representations with growing visual expertise for synthetic shapes.

If you are using MD758 parcellation please refer to [MD758 parcellation](https://github.com/cognitive-biology/Parcellation) and cite accordingly.
##Requirements##
 You need following requirements to run DLDA:

- MATLAB (tested on version 9.3 and 9.12)
- [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)
- NIFTI toolbox (niftimatlib; download [here](https://github.com/NIFTI-Imaging/nifti_matlab))
- [MD758 parcellation](https://github.com/cognitive-biology/Parcellation) (already included)

##How to use##
First, download or clone the repository. NIFTI toolbox should be installed and included in the MATLAB path. Before following the pipeline, you can go over the [demo](https://github.com/cognitive-biology/DLDA/blob/main/demo.m) file as an example of how to use this toolbox.

**WARNING:** Due to large amount of data that fMRI images contain, this process can be memory consuming. Make sure to save any unsaved processes before running this program. 

###Pipeline:###
After having your fMRI images preprocessed, first you need to create a setting and a profile structure array which contain the necessary information for the DLDA pipeline. The setting and profile structures should include the following information:

	%% stg (settings) 
	stg.atlasnii % 'path_to_atlas_nifti_file.nii' (.nii only)
	stg.atlaslist % 'path_to_atlas_list.mat' atlas region information
	stg.ROI_ID  % array of ROIs
	stg.window % [TR1 TR2] (event centered windows from TR1 to TR2)
	stg.TR % fMRI TR in seconds
	stg.classificationID % ID of the classes for classification
	stg.Nrepetition % number of train-test repetition
	stg.TestFraction % fraction of data used for cross-validation 
	stg.StatsPermutations % number of first-level permutation test 
	stg.PrevalencePermutations % number of second-level permutation test (prevalence analysis)
	stg.alpha % level of significance
	stg.SaveDirectory % directory in which toolbox will save the output files
	
	%% prf (profile) is a structure of 1-by-N (N: number of images)
	prf(i).subject % name or ID of the subject
	prf(i).images % path to the pre-processed .nii image file 
	prf(i).ID % ID of the events (trigger:-3, ID of the class presented)
	prf(i).time % time of the events (MR trigger and class presentation)
	

 Once these information is provided you can take follow the [DLDA pipeline](https://github.com/cognitive-biology/DLDA/blob/main/DLDA_pipeline.m) which takes the setting and profile variables and performs the following steps:
 
 1. **Checking settings and profile:**
	`check_inputs(stg,prf)` controls for missing fields of the assigned variables.
2. **Preparing saving directory:** `prepare_savedir(stg,prf)` creates all the required folders under the `stg.SaveDirectory` directory.
3. **Splitting original image:** `split_images(stg,prf)` divides the original preprocessed images into smaller files for each given ROI, for each subject.
4. **Sequencing events:** `get_sequences(stg,prf)` recognizes TR indices for all events. 
5. **Cleaning ROI data:** `get_clean_data(stg,prf,ROI)` whitens and detrends data for a given ROI. 
6. **Combine class data over sessions:** `get_class_data(stg,prf,clean_data)` combines the cleaned data over sessions and divides them by classes.
7. **Dividing train/test sets:** `train_test_division(stg,class_data)` divides the combined class data into train and test sets.
8. **Training classifier:** `training_optimal_space(TrainBatch)` finds the optimal subspace and the centroids of each class in that subspace.
9. **Crossvalidation of classifier:** `test_classification(TestBatch,G)` projects the test-set into the optimal subspace *G*. Then, `test_stats(stg,projected_test_data,M)` provides multiple cross-validation measures and performs the first-level permutation.


###Prevalence statistics:###
Additionally, we have included `get_prevalence` which performs a population prevalence inference using a 2-level permutation test [Allefeld et al. 2016](https://doi.org/10.1016/j.neuroimage.2016.07.040). 

##Licence##
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.