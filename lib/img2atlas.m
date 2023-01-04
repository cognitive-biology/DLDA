function out_data = img2atlas(atlasnii,atlaslist,image,varargin)
% IMG2ATLAS finds regions to which voxels of an image belong, for a given
% atlas.
%
% OUT_DATA = IMG2ATLAS(ATLASNII,ATLASLIST,IMAGE) gets the atlas nifti file
% ATLASNII, list of regions ATLASLIST and the image nifti file IMAGE and
% fits the image to the given atlas. Then, an atlas-fitted image OUT_DATA
% (N-by-4 cell) is created contains the region's code, name, index of voxels
% in each region and their values/time series. 
%
% IMG2ATLAS(ATLASNII,ATLASLIST,IMAGE,Property1,Value1) initializes property
%   Property1 to Value1.
%   Admissible property:
%       save     -   file name to save
%
% See also local_corr, open_nii.
%
% J. V. Dornas, E. Kakaei, J. Braun 2018
% (https://github.com/cognitive-biology/Parcellation)

%% initialize
save_file = false;
for n = 1:1:length(varargin)-1
    switch varargin{n}
        case 'save'
            save_file = varargin{n+1};
            if ~ischar(save_file)
                error('file name should be character')
            end
    end
end
% import
atlas = open_nii(atlasnii); % nifti file of atlas
[img,img_name,img_path]= open_nii(image); % image file
list = load(atlaslist); % load list of atlas names (ROI)

if ~isfield(list,'ROI')
    error('ROI not defined in brain atlas list')
end
ROI = list.ROI;

atlas_data = atlas.dat(); 
atlas_size = size(atlas_data);

data = img.dat;
data_size = size(data);
atlas_vec = atlas_data(:);
data_vec = data(:);
% dimension check
if atlas_size(1:3)~=data_size(1:3)
    error('image file and atlas file do not have same dimension')
end

atlas_regions = unique(atlas_data);
out_data = cell(length(atlas_regions),4); %{code name voxels_index voxels_data}
disp(['fitting ',fullfile(img_path,img_name),' to atlas ...\n'])
for ind = 1:length(atlas_regions)
    
    ID_index = find(atlas_vec==atlas_regions(ind));
    name_index = find([ROI.ID]== atlas_regions(ind));
    
    if length(name_index)>1
        error('Problem with atlas. ROI ID mismatch') 
    elseif ~isempty(name_index) 
        out_data{ind,2} = ROI(name_index).Nom_L; % ROI name
    else
        out_data{ind,2} = ''; % voxels NOT included in ROI
    end
    
    out_data{ind,1} = atlas_regions(ind); % ROI code
    out_data{ind,3} = ID_index; % indices of voxels in ROI
    reg_data = zeros(size(data,4),length(ID_index));
    tmp_index = ID_index;
    % time series
    for t = 1:size(data,4)
        reg_data(t,:) = data_vec(tmp_index);
        tmp_index = tmp_index+length(atlas_vec);
    end
    out_data{ind,4} = reg_data;
end
%% save file
if save_file
    fprintf(['saving ',save_file,' ...\n'])
    matfile = fullfile(img_path, [save_file '.mat']);
    save(matfile,'out_data','-v7.3')
end

end