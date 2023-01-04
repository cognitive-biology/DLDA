function [G_prime, M_class,class_size]  = training_optimal_space(TrainBatch)
% gets the training batch and find the optimal space
%
% [G_PRIME, M_CLASS,CLASS_SIZE]  = TRAINING_OPTIMAL_SPACE(TRAINBATCH) gets
% the training set TRAINBATCH, trains the DLD classifier and returns the
% projection matrices G_PRIME, centroid of the classes M_CLASS, and number
% of data points in each class CLASS_SIZE.
%
% For the original DLDA algorithm see:
% Yu and Yang 2001 & Ye et al. 2006.
%
% Ehsan Kakaei, Jochen Braun 2021
% (https://github.com/cognitive-biology/DLDA)
%
% See also test_classification, train_test_division.

disp('Training Direct LDA classifier...')
TrainBatch_data = TrainBatch.data;

NClass = size(TrainBatch_data,1);
NSubject = size(TrainBatch_data,2);
G_prime = cell(NSubject,1);
M_class = cell(NSubject,1);
class_size = cell(NSubject,1);
if NSubject~=numel(TrainBatch.subjects)
    error('Number of subjects mismatch!')
end
for ns = 1:NSubject
    Current_Data = TrainBatch_data(:,ns);
    dummy = cell2mat(Current_Data');
    Ntotal = size(dummy,2); % total number of training samples
    Ndim = size(dummy,1); % NTRs*NVoxels
    
    Centroid_total = mean(dummy,2);
    %%  assemble H_b and H_w
    
    H_b = nan( Ndim, NClass );
    
    H_w = nan( Ndim, Ntotal );
    
    n_k = nan( 1,NClass );      % sample number
    
    c_k = nan( Ndim, NClass );  % class mean
    
    kend = 0;
    
    for k = 1 : NClass            % loop over all objects
        
        n_k(k) = size( Current_Data{k}, 2 );
        
        c_k(:,k) = mean( Current_Data{k}, 2 );
        
        krange = kend+1:kend+n_k(k);
        
        H_b(:,k) = sqrt(n_k(k))*(c_k(:,k)-Centroid_total)/sqrt(Ntotal);
        
        H_w(:,krange) = (Current_Data{k} - c_k(:,k) * ones(1,n_k(k)))/sqrt(Ntotal);
        
        kend = kend+n_k(k);
        
    end
%% Step 1 of direct LDA: diagonalize S_b = H_b * H_b' and whiten / unitize

precision = 1.e-12;

[Y_b, Lambda_b] = Apply_Lemma_1( H_b', precision );        % get eigenvectors with nonzero eigenvalues
Z_b = Y_b * sqrt( inv( diag( Lambda_b ) ) );               % rescale
%% Step 2 of direct LDA: rotate S_w into Z space and diagonalize Z_b' * H_w * H_w' * Z_b
% Diagonalize

H_r = Z_b' * H_w;

[~, D_w, U_w] = svd( H_r * H_r' );
Lambda_w      = diag(D_w);

%% Step 3 of direct LDA: form the LDA projection matrix that maximizes discriminability

G = U_w' * Z_b';                                         % linearly projected data

current_Gprime = sqrt( inv( diag( Lambda_w ) ) ) * G;           % 'sphered' data

%% Step 4: project training data into reduced space, also for novel objects

X_k    = cell( 1, NClass);          % class data
x_k    = nan( NClass-1, NClass);  % class mean
n_k = nan(1,NClass); % class size

for k = 1 : NClass
    
    X_k(k) = num2cell( current_Gprime * Current_Data{k}, [1 2]);
    
    x_k(:,k) = mean(X_k{k},2);
    n_k(k) = size(X_k{k},2);
end
G_prime(ns) = {current_Gprime};
M_class(ns) = {x_k};
class_size(ns) = {n_k};
end
end
function [V, Lambda] = Apply_Lemma_1( L, precision )
%% Lemma 1
checkflag = 0;

[m, n] = size( L );                                          % rectangular matrix, m < n

Small = L * L';                                              % square matrix m x m


[~, Diag_small, V_small] = svd( Small );                     % eigenanalysis of small                                                          % eigenanalysis of Small
Lambda_small = diag( Diag_small );

kk = find( abs( Lambda_small ) > precision );
V_small      = V_small(:,kk);                                % non-zero eigenvectors and -values
Lambda_small = Lambda_small(kk);

if checkflag
    
    Large = L' * L;                                              % square matrix n x n
    
    [~, Diag_large, V_large] = svd( Large );                     % eigenanalysis of large                                                          % eigenanalysis of Small
    Lambda_large = diag( Diag_large );
    
    kk = find( abs( Lambda_large ) > precision );
    V_large      = V_large(:,kk);                                % non-zero eigenvectors and -values
    Lambda_large = Lambda_large(kk);
    
end

U_large = L' * V_small;                                      % projection from small to large

U_large = U_large * sqrt( inv( diag( Lambda_small ) ) );

if checkflag
    C = V_large' * U_large                                       % comparison of large eigenvectors (should be diagonal matrix)
    
    U_large' * Large * U_large   - diag(Lambda_small)            % comparison of large and small eigenvalues, should be zero
end

V      = U_large;                                            % return projected eigenvector
Lambda = Lambda_small;                                       % return eigenvalues

end