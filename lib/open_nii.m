function [data,FileName,PathName] = open_nii(file)
% OPEN_NII opens files with .nii format using the NifTI Toolbox
% (nifti.nimh.nih.gov/nifti-1/). Please download and include it in the
% path.
%
% [DATA,FILENAME,PATHNAME] = OPEN_NII(FILE) outputs the data DATA of the FILE
%  with .nii format and provides the file name FILENAME and path PATHNAME.
%
% See also nifti, save_nii.
%
% E. Kakaei, J. V. Dornas, J. Braun 2018

switch computer
    case {'PCWIN' ,'PCWIN64'}
        symbol = '\'; % path style in Windows
    case {'MACI64' ,'MACI','GLNXA64','GLNXA'}
        symbol = '/'; % path style in OS and Linux
end

if ischar(file)
    data = nifti(file);
    crind = strfind(file,symbol);
    FileName = file(crind(end)+1:end);
    PathName = file(1:crind(end));
else
    error('a valid file should be selected')
end

end