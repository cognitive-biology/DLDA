function projected_test = test_classification(TestBatch,G_prime)
% projects the test set and to the discriminant space using projection
% matrix, and returns the projected test data.
%
% PROJECTED_TEST = TEST_CLASSIFICATION(TESTBATCH,G_PRIME) gets the test set
% TESTBATCH and projection matrices G_PRIME and returns the projected test
% data PROJECTED_TEST.
%
% Ehsan Kakaei, Jochen Braun 2021
% (https://github.com/cognitive-biology/DLDA)
% 
% See also test_stats, train_test_division,training_optimal_space.


%% project test data into reduced space
TestBatch_data = TestBatch.data;
NClass = size(TestBatch_data,1);
NSubject = size(TestBatch_data,2);
projected_test_data = cell(NClass,NSubject); % Test data projected to 'optimal space' 
if NSubject~=numel(TestBatch.subjects)
    error('Number of subjects mismatch!')
end
for ns = 1:NSubject
    Current_Data = TestBatch_data(:,ns);
    current_Gprime = G_prime{ns};
   
    for k = 1 : NClass
        projected_test_data(k,ns) = num2cell( current_Gprime * Current_Data{k}, [1 2]);       
    end
end
projected_test.data = projected_test_data;
projected_test.subjects = TestBatch.subjects;
end