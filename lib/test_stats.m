function [F,acc,conf,SSWs,SSBs,F_rand,acc_rand,conf_rand,SSWs_rand,SSBs_rand] = test_stats(stg,projected_test,M_class)
% gets the projected test set and centroids of the training sets, and
% returns multiple cross-validation measures.
%
% [F,ACC,CONF,SSWS,SSBS] = test_stats(STG,PROJECTED_TEST,M_CLASS) gets the
% projected test set PROJECTED_TEST and the centroids of the training sets
% M_CLASS and returns f-ratio F, accuracy ACC, confusion matrix CONF,
% scatter within class SSWS and scatter between classes SSBS.
%
% [F,ACC,CONF,SSWS,SSBS,F_RAND,ACC_RAND,CONF_RAND,SSWS_RAND,SSBS_RAND] = 
% test_stats(STG,PROJECTED_TEST,M_CLASS) performs a permutation test
% shuffling the IDs of classes and returns the measured shuffled values 
% F_RAND,ACC_RAND,CONF_RAND,SSWS_RAND,and SSBS_RAND.
%
% Ehsan Kakaei, Jochen Braun 2021

disp('cross-validating...')


projected_test_data = projected_test.data;
NClass = size(projected_test_data,1);
NSubject = size(projected_test_data,2);
nshuffle = stg.StatsPermutations;

% measured values
F = nan(NSubject,1);
SSBs = nan(NSubject,1);
SSWs = nan(NSubject,1);
acc = nan(NSubject,1);
conf = nan(NClass,NClass,NSubject);

% permutation values
F_rand = nan(NSubject,nshuffle);
acc_rand = nan(NSubject,nshuffle);
conf_rand = nan(NClass,NClass,NSubject,nshuffle);
SSBs_rand = nan(NSubject,nshuffle);
SSWs_rand = nan(NSubject,nshuffle);

if nargout>5
    shuffle = true;
else
    shuffle = false;
    if nshuffle>0
        warning('No permutations are requested!')
    end

end

for ns = 1:NSubject
    current_data = projected_test_data(:,ns);
    dat = cell2mat(current_data');
    M = M_class{ns}; % centroids of training class
    
    Nsample = cellfun(@(x) size(x,2),current_data); % number of test samples
    cNsample = cumsum(Nsample);
    
    ndim = size(dat,1); % dimension of the optimal space
    g = zeros(1,cNsample(end)); % class ID
    
    c_overall = mean(dat,2); % Centroid of all datapoints
    c_k = nan(ndim,NClass); % centroid of test classes
    n_k = nan(1,NClass); % number of test points within class
    ssw_k = nan(1,NClass); % within class variance of test data
    for nc = 1:NClass
        if nc==1
            g(1:Nsample(1)) = 1; % classes
        else
            g(cNsample(nc-1)+1:cNsample(nc)) = nc;
        end
        tmpdat = dat(:,g==nc);
        n_k(nc) = size(tmpdat,2);
        c_k(:,nc) = mean(tmpdat,2);
        ssw_k(nc) = sum(sum((tmpdat-mean(tmpdat,2)).^2));
    end
    SSW = sum(ssw_k);
    SSB = sum(n_k.*sum((c_k-c_overall).^2)); % varaince Between
    tmpF = (SSB/(NClass-1))/(SSW/(cNsample(end)-NClass)); % F-ratio (MANOVA)
    SSBs(ns) = SSB/(NClass-1); % normalized between class scatter
    SSWs(ns) = SSW/(cNsample(end)-NClass); % normalized within class scatter
    F(ns) = tmpF;
    % accuracy
    d = pdist2(M',dat','euclidean');
    [~,id] = min(d);
    acc(ns) = mean(id==g); % accuracy
    tmpconf = zeros(NClass); % confusion matrix
    for ind = 1:length(id)
        tmpconf(g(ind),id(ind)) = tmpconf(g(ind),id(ind))+1;
    end
    conf(:,:,ns) = tmpconf;
    
    %% permutation test
    if nshuffle>0 && shuffle
        
        for nperm = 1:nshuffle
            random_idx = randperm(length(g)); % shuffle datapoint IDs
            shuffle_dat = dat(:,random_idx);
            c_k = nan(ndim,NClass);
            n_k = nan(1,NClass);
            ssw_k = nan(1,NClass);
            for nc = 1:NClass
                tmpdat = shuffle_dat(:,g==nc);
                n_k(nc) = size(tmpdat,2);
                c_k(:,nc) = mean(tmpdat,2);
                ssw_k(nc) = sum(sum((tmpdat-mean(tmpdat,2)).^2));
            end
            SSW = sum(ssw_k);
            SSB = sum(n_k.*sum((c_k-c_overall).^2));
            
            tmpF = (SSB/(NClass-1))/(SSW/(cNsample(end)-NClass));
            
            % accuracy
            d = pdist2(M',shuffle_dat','euclidean');
            [~,id] = min(d);
            tmpacc = mean(id==g); % accuracy
            tmpconf = zeros(NClass); % confusion matrix
            for ind = 1:length(id)
                tmpconf(g(ind),id(ind)) = tmpconf(g(ind),id(ind))+1;
            end
            F_rand(ns,nperm) = tmpF;
            conf_rand(:,:,ns,nperm) = tmpconf;
            acc_rand(ns,nperm) = tmpacc; % accuracy
            SSBs_rand(ns,nperm) = SSB/(NClass-1);
            SSWs_rand(ns,nperm) = SSW/(cNsample(end)-NClass);
        end
    end
end
end