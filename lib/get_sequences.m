function seq = get_sequences(stg,prf,dontsave)
% provides indices of TRs which should be used for each class and each
% image.
%
% GET_SEQUENCES(STG,PRF) reads presentation time and imaging
% acquision time as well as ID of the object/classes presented from the
% PRF variable and saves the TR indices of each presentation for each
% measurement window (event-centered). 
%
% Ehsan Kakaei, Jochen Braun 2021

disp('Finding the sequences of each class...')

if nargin<3
    dontsave = false;
end
classificationID = stg.classificationID; % which classes to train on
Nclass = numel(classificationID);
imgs = {prf(:).images};
Nimages = numel(imgs);
TR = stg.TR; 
window = stg.window; % event 'centered' window  in TRs (event+window(1)*TR:event+window(2)*TR)

save_dir = stg.SaveDirectory;
seq = cell(Nimages,Nclass);
for ni = 1:Nimages
    if ~isfield(prf,'Progress_sequences') || isempty(prf(ni).Progress_sequences) ...
            || prf(ni).Progress_sequences~=true
        time = prf(ni).time; % time of events
        ID = prf(ni).ID; % ID of event
        trigger_time = time(ID==-3); % Acquisition times
        NTRs = numel(trigger_time); % number of TRs
        for nc = 1:Nclass
            current_class = classificationID(nc);
            idx = find(ID==current_class); % which events is in current class
            Nevents = numel(idx);
            EV = nan(window(2)-window(1)+1,Nevents); % TRs by number of events
            for nev = 1:Nevents
                t_event = time(idx(nev)); % event time
                t_w1 = t_event+(window(1)*TR); % onset of the window
                TR_w1 = find(trigger_time<t_w1,1,'last'); % TR corresponding to onset
                if TR_w1>0  % only events within acquisition period
                    TR_w2 = TR_w1+(window(2)-window(1));
                    if TR_w2<NTRs
                        EV(:,nev) = TR_w1:TR_w2;
                    end
                end
            end
            faulty_events = find(sum(isnan(EV),1)); % events window out of acquisition boundary
            EV(:,faulty_events) = [];
            seq(ni,nc) = {EV};
        end
        prf(ni).Progress_sequences = true;
    end
end
if ~dontsave
    save(fullfile(save_dir,['sequences_window' num2str(window(1)) '_' num2str(window(2)) '.mat']),'seq','stg','prf','-v7.3')
end
end
