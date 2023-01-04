function check_inputs(stg,prf)
% gets Settings and profile variables and checks for the required fields
%
% CHECK_INPUTS(STG,PRF) gets STG and PRF structured variables and checks 
% for the required fields of each. 
%
% Ehsan Kakaei, Jochen Braun 2021
% (https://github.com/cognitive-biology/DLDA)

disp('Checking inputs...')
% check inputs
stg_fields = {'atlasnii','atlaslist','window','TR','classificationID',...
    'SaveDirectory','ROI_ID','Nrepetition','TestFraction','StatsPermutations',...
    'PrevalencePermutations','alpha'}; % necassary Settings fields 
prf_fields = {'subject','images','ID','time'}; % necassary profile fields
% check for the structure fields
if ~isstruct(stg) || ~isstruct(prf)
    error('Setting and profile should be structures')
elseif ~prod(isfield(prf,prf_fields)) ||  ~prod(isfield(stg,stg_fields))
   missing_profile = find(~isfield(prf,prf_fields));
   missing_settings = find(~isfield(stg,stg_fields));
   if ~isempty(missing_profile)
       error('following field of profile is missing: %s \n',prf_fields{missing_profile})
   end
   
   if ~isempty(missing_settings)
       error('following field of settings is missing: %s \n',stg_fields{missing_settings})
   end
end

end