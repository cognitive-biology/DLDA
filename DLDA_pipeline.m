function  DLDA_pipeline(stg,prf)
% gets the setting and profile variables and performs DLDA.
% 
% DLDA_PIPELINE(STG,PRF) gets the setting STG and profile PRF and performs
% all the necessary steps for direct linear discriminant analysis (DLDA).
% 
% Ehsan Kakaei, Jochen Braun 2022 
% (https://github.com/cognitive-biology/DLDA)

%% check settings and profile
check_inputs(stg,prf)

%% prepare saving directory

prepare_savedir(stg,prf)

%% split original data to different parcels, for different subjects

split_images(stg,prf)

%% get sequence

get_sequences(stg,prf)

for nr = 1:numel(stg.ROI_ID)
    ROI_ID = stg.ROI_ID;
    current_ROI = ROI_ID(nr);
    %% clean data
    
    clean_data = get_clean_data(stg,prf,current_ROI);
    
    %% combine data between sessions
    
    cls_Data = get_class_data(stg,prf,clean_data);
    
    %% Train and Test
    % observed values
    F = cell(stg.Nrepetition,1); % F-ratio
    acc = cell(stg.Nrepetition,1); % accuracy
    conf = cell(stg.Nrepetition,1); % confusion matrix
    SSWstar = cell(stg.Nrepetition,1); % within class scatter
    SSBstar = cell(stg.Nrepetition,1); % between class scatter
    % shuffled values
    F_rand = cell(stg.Nrepetition,1); % F-ratio
    acc_rand = cell(stg.Nrepetition,1); % accuracy
    conf_rand = cell(stg.Nrepetition,1); % confusion matrix
    SSWstar_rand = cell(stg.Nrepetition,1); % within class scatter
    SSBstar_rand = cell(stg.Nrepetition,1); % between class scatter
    
    for nrep = 1:stg.Nrepetition
        %% divide test and training sets
        
        [TrainBatch,TestBatch] = train_test_division(stg,cls_Data);
        
        %% train Direct linear discriminant
        
        [G_prime, M_class]  = training_optimal_space(TrainBatch);
        
        %% test the classification performance
        
        projected_test_data = test_classification(TestBatch,G_prime);
        
        %% get statistics
        
        [F{nrep},acc{nrep},conf{nrep},SSWstar{nrep},SSBstar{nrep},...
            F_rand{nrep},acc_rand{nrep},conf_rand{nrep},SSWstar_rand{nrep},...
            SSBstar_rand{nrep}] = test_stats(stg,projected_test_data,M_class);
        
    end
    %% save test results
    save(fullfile(stg.SaveDirectory,'Results','ROI_ID',num2str(current_ROI),...
        'test_results.mat'),'stg','prf','F','acc','conf','SSWstar','SSBstar',...
        'F_rand','acc_rand','conf_rand','SSWstar_rand','SSBstar_rand','-v7.3')
end
end