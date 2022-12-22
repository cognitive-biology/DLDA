function [PN,PNstar,gamma0,mv] = get_prevalence(V,V_rnd,alpha,perms,StatNtest)
% m and m_rnd are cells of (Nrepetition-by-NROIs)

Nrepetition = size(V,1);
NROIs = size(V,2);
mv = zeros(NROIs,1); % minimum observation value between subject, per ROI
mv_rand = zeros(NROIs,perms);% minimum second-level observation  between subject over random sample, per ROI
PN = nan(NROIs,1); % Uncorrected P-value
PNstar = nan(NROIs,1); % corrected P-value
gamma0 = zeros(NROIs,1); % Prevalence
for Nr = 1:NROIs
    disp([num2str(ceil(100*Nr/NROIs)) ' %'])
    m = V(:,Nr);
    m_rnd = V_rnd(:,Nr);
    
    m = transpose(m(:)); % row
    m_rnd = transpose(m_rnd(:)); % row
    
    m_mat = cell2mat(m);
    m_rnd_mat = cell2mat(m_rnd);
    Nsubjects = size(m_mat,1);
    
    m_rnd_mat = reshape(m_rnd_mat,Nsubjects,StatNtest,Nrepetition);
        
    Observations = zeros(Nsubjects,1);
    Shuffled_Observations = zeros(Nsubjects,StatNtest);
    random_idx = randi(StatNtest,Nsubjects,perms); % shuffle random observations between observers
    rand_sample = zeros(Nsubjects,perms); % Second-level random sample
    for Ns = 1:Nsubjects
        Observations(Ns) = mean(m_mat(Ns,:),2);
        Shuffled_Observations(Ns,:) = mean(m_rnd_mat(Ns,:,:),3); % First-level average over each permutation
        rand_sample(Ns,:) = Shuffled_Observations(Ns,random_idx(Ns,:));
    end
    mv(Nr) = min(Observations); % minimun observation between subjects
    mv_rand(Nr,:) = squeeze(min(rand_sample)); % minimun second-level observation between subjects
end
Mj = max(mv_rand); % maximum second-level observation between ROIs

for Nr = 1:NROIs
    PN(Nr) = (1+sum(mv(Nr)<=mv_rand(Nr,:)))./(size(mv_rand,2)+1);
    PNstar(Nr) = (1+sum(mv(Nr)<=Mj(:)))./(size(mv_rand,2)+1);
end
%% step5b
alphastar = (alpha-PNstar)./(1-PNstar);
for Nr = 1:NROIs
    if PN(Nr)<=alphastar(Nr)
        gamma0(Nr) = (nthroot(alphastar(Nr),Nsubjects)-nthroot(PN(Nr),Nsubjects))/(1-nthroot(PN(Nr),Nsubjects));
    end
end
end