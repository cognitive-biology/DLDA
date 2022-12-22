function prepare_savedir(stg,prf)
% prepares the directory in which new files, results and folders will be
% saved.
%
% PREPARE_SAVEDIR(STG,PRF) gets the STG and PRF variables and prepares the 
% required folders in which the pipeline will save the results and new 
% files.
%
% Ehsan Kakaei, Jochen Braun 2021

disp('preparing save directory ...')
Subjects = {prf(:).subject};
individual_sub = unique(Subjects);
Nsubjects = numel(individual_sub);

ROI = stg.ROI_ID;
Nroi = numel(ROI);

save_dir = stg.SaveDirectory;
%% splitted images
for ns = 1:Nsubjects
    if ~isdir(fullfile(save_dir,'Sub',individual_sub{ns}))
        mkdir(fullfile(save_dir,'Sub',individual_sub{ns})) % subjects folder
        for nr = 1:Nroi
            current_ROI = ROI(nr);
            mkdir(fullfile(save_dir,'Sub',individual_sub{ns},'ROI_ID',num2str(current_ROI))) % ROI folders
        end
    else
        for nr = 1:Nroi
            current_ROI = ROI(nr);
            if ~isdir(fullfile(save_dir,'Sub',individual_sub{ns},'ROI_ID',num2str(current_ROI)))
                mkdir(fullfile(save_dir,'Sub',individual_sub{ns},'ROI_ID',num2str(current_ROI)))
            end
        end
    end
    idx = find(ismember(Subjects,individual_sub{ns}));
end
%% Clean data
if ~isdir(fullfile(save_dir,'Clean_data'))
    mkdir(fullfile(save_dir,'Clean_data')) % subjects folder
    for nr = 1:Nroi
        current_ROI = ROI(nr);
        mkdir(fullfile(save_dir,'Clean_data','ROI_ID',num2str(current_ROI))) % ROI folders
    end
else
    for nr = 1:Nroi
        current_ROI = ROI(nr);
        if ~ isdir(fullfile(save_dir,'Clean_data','ROI_ID',num2str(current_ROI))) % ROI folders
            mkdir(fullfile(save_dir,'Clean_data','ROI_ID',num2str(current_ROI))) % ROI folders
        end
    end
end
%% results of the validation test
if ~isdir(fullfile(save_dir,'Results'))
    mkdir(fullfile(save_dir,'Results')) % subjects folder
    for nr = 1:Nroi
        current_ROI = ROI(nr);
        mkdir(fullfile(save_dir,'Results','ROI_ID',num2str(current_ROI))) % ROI folders
    end
else
    for nr = 1:Nroi
        current_ROI = ROI(nr);
        if ~ isdir(fullfile(save_dir,'Results','ROI_ID',num2str(current_ROI))) % ROI folders
            mkdir(fullfile(save_dir,'Results','ROI_ID',num2str(current_ROI))) % ROI folders
        end
    end
end
end