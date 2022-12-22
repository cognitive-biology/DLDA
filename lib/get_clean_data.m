function clean_data = get_clean_data(stg,prf,roi)
% gets data extracted for a desired ROI and whitens and detrends the
% data.
%
% CLEAN_DATA = GET_CLEAN_DATA(STG,PRF,ROI)gets data extracted
%  for a desired ROI, returns whitened and detrended data
% CLEAN_DATA (NImages-by-1 cell), and saves the cleaned data in the results
% folder.
%
% Ehsan Kakaei, Jochen Braun 2021

disp(['Cleaning data ROI_ID ',num2str(roi) '...'])

Subjects = {prf(:).subject};
individual_sub = unique(Subjects);
Nsubject = numel(individual_sub);
save_dir = stg.SaveDirectory;

clean_data = cell(numel(Subjects),1);

for ns = 1:Nsubject % over subjects
    subname = individual_sub{ns};
    idx = find(strcmp(subname,Subjects)); % indexes in profile and ROI_ID 
    
    for ni = 1:numel(idx) % over images
        current_idx = idx(ni);
        fullname = fullfile(save_dir,'Sub',subname,'ROI_ID',num2str(roi),[num2str(current_idx) '.mat']);
        current_image = load(fullname); % splitted image of current class and subject for the given ROI
        data = current_image.data;
        data = detrend(data); % detrending data
        
        NTRs = size(data,1);
        NVoxels = size(data,2);
        
        for nv = 1 : NVoxels            % whiten each dimension (zero-mean,unit variance)
            v = squeeze( data( :, nv ) );
            data( :,nv ) = ( v - nanmean(v) ) / nanstd(v);
        end
        
        if sum(isnan(data(:)))
            data( isnan(data) ) = 0;
        end
        clean_data(current_idx) = {data}; % same order as in Profile
    end
end
fullname = fullfile(save_dir,'Clean_data','ROI_ID',num2str(roi),'clean_data.mat'); % file name indexed as it is indexed in profile

save(fullname,'clean_data','prf','stg','-v7.3')
end