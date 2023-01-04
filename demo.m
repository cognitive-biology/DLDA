function demo
% This demo file generates some artificial data and demonstrates how to
% implement the direct linear discriminant analysis (DLDA), as well as
% prevalence statistics.
% 
% Prerequisit: niftimatlib-1.2 toolbox (https://github.com/NIFTI-Imaging/nifti_matlab)
%
% Ehsan Kakaei, Jochen Braun 2022
% (https://github.com/cognitive-biology/DLDA)
% 
% see also DLDA_pipeline.

%% flags and initialization
generate_data = 1;
execute_pipeline = 1;

addpath(genpath('.'))
if nargin<1
    nii_path = which('nifti');
    if isempty(nii_path)
        error('niftimatlib toolbox is not on MATLAB`s path!')
    end
end
%% settings
% parcellation
stg.atlasnii = fullfile('.','atlas','MD758','ROI_MNI_MD758.nii'); % nifti file of the parcellation
stg.atlaslist = fullfile('.','atlas','MD758','ROI_MNI_MD758_List.mat'); % list of the parcels
stg.ROI_ID = 400; % for demo only one parcel! otherwise stg.ROI_ID = 1:758; 
% constants
stg.window = [2 10]; % TRs (event+Event_window(1):event+Event_window(2)).
stg.TR = 1; % seconds
stg.classificationID = 1:15; % IDs used for classification
stg.Nrepetition = 10; % how many repetition of train-test
stg.TestFraction = 0.1; % what fraction of data should be used as a test
stg.StatsPermutations = 1e3; % numper of permutation tests
stg.PrevalencePermutations = 1e5; % numper of permutation for Prevalence test
stg.alpha = 0.05; % level of significance
% saving directory 
stg.SaveDirectory = fullfile('.','demo_outputs'); % !!!assign your directory!!!!

%% Create artificial data
if generate_data
    if ~isfolder(fullfile(stg.SaveDirectory,'data'))
        mkdir(stg.SaveDirectory,'data')
    end
    Nsubjects = 2;
    Nruns = 2;
    NTRs = 600;
    
    jj = 0;
    for ns = 1:Nsubjects
        name = ['sub' num2str(ns)];
        for ni = 1:Nruns
            jj = jj+1;
            [~,time,ID,fname] = generate_artificial_data(stg,NTRs);
            prf(jj).subject = name; % subject name or ID
            prf(jj).images = fname; % nifti images
            prf(jj).ID = ID; % Event's ID (trial + MR trigger)
            prf(jj).time = time; % Time stamps of events
        end
    end
    save(fullfile(stg.SaveDirectory,'profile_and_Settings.mat'),'prf','stg')
else
    load(fullfile(stg.SaveDirectory,'profile_and_Settings.mat'))
end
%%  DLDA pipeline
if execute_pipeline
    DLDA_pipeline(stg,prf)
end
%% Evaluate the results
[PN,PNstar,gamma0,mv,mu] = evaluation(stg);
accuracy.PN = PN; % Uncorrected p-val for global null hypothesis
accuracy.PNstar = PNstar; % p-val spatially extended global null hypothesis
accuracy.gamma0 = gamma0; % Prevalence
accuracy.mv = mv; % minimum statistics
accuracy.mean = mu; % average accuracy
save(fullfile(stg.SaveDirectory,'Results','Direct_LDA_evaluation.mat'),'accuracy','-v7.3')
end
function [PN,PNstar,gamma0,mv,mu] = evaluation(stg)
%% collect results of all ROIs
V = cell(stg.Nrepetition,numel(stg.ROI_ID));
V_rnd = cell(stg.Nrepetition,numel(stg.ROI_ID));
for nr = 1:numel(stg.ROI_ID)
    ROI_ID = stg.ROI_ID;
    current_ROI = ROI_ID(nr);
    x = load(fullfile(stg.SaveDirectory,'Results','ROI_ID',num2str(current_ROI),...
        'test_results.mat'));
    V(:,nr) = x.acc;
    V_rnd(:,nr) = x.acc_rand;
end
mu =  mean(cell2mat(V));
%% calculate prevalence
alpha = stg.alpha;
perms = stg.PrevalencePermutations;
StatNtest = stg.StatsPermutations;
[PN,PNstar,gamma0,mv] = get_prevalence(V,V_rnd,alpha,perms,StatNtest);

end
function [data,time,ID,fname] = generate_artificial_data(stg,NTRs)
% gets settings and number of TRs and generates an artificial fMRI
% sequence.
% 
% [DATA,TIME,ID,FNAME] = GENERATE_ARTIFICIAL_DATA(STG,NTRS) get the setting
% variable STG and number of TRs NTRS, and returns fMRI data DATA, event
% times TIMES, events' ID, name of the artificial nifti file FNAME and
% saves the nifti file under the STG.SaveDirectory.
%
% 
% ID corresponds to sequence of each trial presentation in form of 
% (-3 Object_ID -3 -3) where -3 represents the MR acquisition triggers. 
%
% Ehsan Kakaei, Jochen Braun 2022

atlasnii = stg.atlasnii;
ROI_ID = stg.ROI_ID;
Npresentations = 200;
ID = -3*ones(NTRs+Npresentations,1);
classes = stg.classificationID;
ii = randi(numel(classes),Npresentations,1);
ID(2:4:end) = classes(ii); % random presentation of classes
time = zeros(size(ID));
time(ID==-3) = 1:600;

img = open_nii(atlasnii);
reference_data = img.dat();
ref_vox_idx = find(reference_data); % all voxels inside atlas
ROI_vox_idx = find(reference_data==ROI_ID); % voxels inside current region

data = zeros(numel(reference_data),NTRs);
for nt = 1:NTRs
    data(ref_vox_idx,nt) = normrnd(0,1,numel(ref_vox_idx),1); % all voxels contain noise
end
x = 0:12;
y = 10*gampdf(x,3,1); % response 
nvox = numel(ROI_vox_idx);
for nc = 1:numel(classes) % classes 
    if nc==1
        responsive_vox{nc} = ROI_vox_idx(1:nc*floor(nvox/numel(classes)));
    else
        responsive_vox{nc} = ROI_vox_idx((nc-1)*floor(nvox/numel(classes)):nc*floor(nvox/numel(classes)));
    end
end
for nev = 1:Npresentations
    time(4*nev-2) = time(4*nev-1)+0.1+0.1*rand;
    current_class = ID(4*nev-2);
    idx = responsive_vox{current_class}; % which voxels respond
    if (nev-1)*3+13 <=NTRs
        data(idx,(nev-1)*3+1:(nev-1)*3+13) = data(idx,(nev-1)*3+1:(nev-1)*3+13)+y;
    end
end
data = reshape(data,[size(reference_data) NTRs]);

%% save as nifti file
fname = fullfile(stg.SaveDirectory,'data',[num2str(randi(1e14)) '.nii']);

prop.mat = img.mat;
prop.mat_intent = img.mat_intent;
prop.mat0 = img.mat0;
prop.mat0_intent = img.mat0_intent;
prop.dim = [img.dat.dim NTRs];
prop.dtype = 'FLOAT32-LE';
prop.offset = img.dat.offset;
prop.scl_slope = img.dat.scl_slope;
prop.scl_inter = img.dat.scl_inter;
prop.descript = strcat('mask',fname);
prop.timing = img.timing;

save_nii(data,fname,prop)
end