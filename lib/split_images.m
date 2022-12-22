function split_images(stg,prf)
% reads the image files indicated in profile and splits them into various
% ROIs indicated in the settings for all observers.
%
%
% SPLIT_IMAGES(STG,PRF) get original pre-processed images indicated in the 
% PRF variable and extracts the data for each ROI of a  desired atlas,both  
% of which defined IN STG variable. Finally, the extracted data are saved
%  in a savedirectory of defined in the STG variable.
%
% Ehsan Kakaei, Jochen Braun 2021

Subjects = {prf(:).subject};
individual_sub = unique(Subjects);
Nsubject = numel(individual_sub);

imgs = {prf(:).images}; % original NIFTI images
Nimages = numel(imgs);

ROI = stg.ROI_ID; 
Nroi = numel(ROI);
save_dir = stg.SaveDirectory;

atlasnii = stg.atlasnii;
atlaslist = stg.atlaslist;

for ni = 1:Nimages
    if ~isfield(prf,'Progress_images_splitted') || isempty(prf(ni).Progress_images_splitted) ...
            || prf(ni).Progress_images_splitted~=true
        
        image = imgs{ni}; % image to split
        subname = prf(ni).subject; % subject name
        
        out_data = img2atlas(atlasnii,atlaslist,image); % fit image to the selected atlas
        atlas_IDs = cell2mat(out_data(:,1)); % ROIs defined in the atlas
        
        idx = find(ismember(atlas_IDs,ROI)); % ROIs to save
        if numel(idx)~=Nroi
            warning('atlas missed some of the ROIs!')
        end
        for nr = 1:Nroi
            current_ROI = ROI(nr);
            idx = find(ismember(atlas_IDs,current_ROI));
            data = out_data{idx,4}; % Data to save
            
            fullname = fullfile(save_dir,'Sub',subname,'ROI_ID',num2str(current_ROI),[num2str(ni) '.mat']); % file name indexed as it is indexed in profile
            source_image_path = image;
            save(fullname,'data','source_image_path','prf','stg','-v7.3')
        end
        prf(ni).Progress_images_splitted = true;
    end
end
end