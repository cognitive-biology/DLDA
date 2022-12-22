function projected_test = test_classification(TestBatch,G_prime)
% gets the test set and projection matrices to the discriminant space, and
% returns the projected test data. 

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