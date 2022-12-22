function save_nii(data,fname,prop)
% SAVE_NII saves files with .nii format using the NifTI Toolbox
% (nifti.nimh.nih.gov/nifti-1/). Please download and include it in the
% path.
%
% SAVE_NII(DATA,FNAME,PROP) saves a nifti file named as FNAME containing
% the data DATA (2D,3D or 4D) with the properties PROP. PROP is a
% structure that contains the following fields:
%
%   PROP.dim            -   dimension of the data
%   PROP.dtype          -   datatype
%   PROP.offset         -   offset into file
%   PROP.scl_slope      -   scale factor
%   PROP.scl_inter      -   offset
%   PROP.mat            -   SForm matrix
%   PROP.mat_intent     -   SForm code
%   PROP.mat0           -   QForm matrix
%   PROP.mat0_intent    -   QForm code
%   PROP.timing         -   slice timing
%   PROP.descript       -   description
%
% See also nifti, open_nii.
%
% E. Kakaei, J. V. Dornas, J. Braun 2018

N = nifti; % nifti object
N.dat = file_array(fname,prop.dim,prop.dtype,prop.offset,prop.scl_slope,...
    prop.scl_inter); % creating file_array objects

% SForm matrix
N.mat = prop.mat; 
N.mat_intent = prop.mat_intent;

% QForm matrix
N.mat0 = prop.mat0;
N.mat0_intent = prop.mat0_intent;

N.descrip = prop.descript; % description

create(N); % write header info

dat = N.dat;
dat.scl_slope = prop.scl_slope;
dat.scl_inter = prop.scl_inter;

% input data
if length(size(data)) == 2
    dat(:,:) = data;

elseif length(size(data)) == 3
    dat(:,:,:) = data;
    
elseif length(size(data)) == 4
    dat(:,:,:,:) = data;
    N.timing = prop.timing;
    
end
end