function cls = get_class_data(stg,prf,clean_data,seq)
% returns the data for each class and each subject for the given ROI.
%
% CLS = GET_CLASS_DATA(SETTINGS,PROFILE,CLEAN_DATA) gets the cleaned data
% CLEAN_DATA of the given ROI and returns the data CLS grouped by classes
% and subjects.
%
% Ehsan Kakaei, Jochen Braun 2021

if nargin<4
    seq = [];
end

disp('arranging data by classes...')

Subjects = {prf(:).subject};
individual_sub = unique(Subjects);
Nsub = numel(individual_sub);

classificationID = stg.classificationID;
Nclass = numel(classificationID);

save_dir = stg.SaveDirectory;
window = stg.window; % event 'centered' window  in TRs (event+window(1)*TR:event+window(2)*TR)
seqfile = fullfile(save_dir,['sequences_window' num2str(window(1)) '_' num2str(window(2)) '.mat']);
if ~isfile(seqfile) && isempty(seq)
    error('sequence data missing. perform get_sequences')
elseif isfile(seqfile) && isempty(seq)
    tmp = load(seqfile);
    seq = tmp.seq; % TR indices for each class and subject 
end

cls_data = cell(Nclass,Nsub);
for ns = 1:Nsub % over subjects
    subname = individual_sub{ns};
    idx = find(strcmp(subname,Subjects)); % indexes in profile and ROI_ID 
    
    for ni = 1:numel(idx) % over images
        current_idx = idx(ni);
        
        data = clean_data{current_idx};
       
        for nc = 1:Nclass % over classes
            current_Sequences = seq{current_idx,nc};
            Nobservations = size(current_Sequences,2);
            for nsample = 1:Nobservations % over obeservations/samples
                trs = current_Sequences(:,nsample); % which TRs of current image
                tmpdata = cls_data{nc,ns};
                current_data = cat(3,tmpdata,data(trs,:)); % concatenate samples/observations over the 3rd dimension of the data
                cls_data(nc,ns) = {current_data};
            end
        end
    end
end
cls.data = cls_data;
cls.subjects = individual_sub; % new order of subjects (NOT same as profile)
end