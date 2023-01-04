function [TrainBatch,TestBatch] = train_test_division(stg,cls)
% gets the data of all classes and subjects and divides them into
% training and testing sets
%
% [TRAINBATCH,TESTBATCH] = TRAIN_TEST_DIVISION(STG,CLS) get the class data
% CLS and divides them into test and training sets TRAINBATCH and
% TESTBATCH.
%
% Ehsan Kakaei, Jochen Braun 2021
% (https://github.com/cognitive-biology/DLDA)
%
% see also get_class_data, training_optimal_space, test_classification.

disp('separating the train and test sets...')
    
cls_data = cls.data;

NClass = size(cls_data,1);
NSubject = size(cls_data,2);
TestFraction = stg.TestFraction;

TrainBatch_data = cell(NClass,NSubject);
TestBatch_data = cell(NClass,NSubject);
for  ns = 1:NSubject
    for nc = 1:NClass
        current_data = cls_data{nc,ns}; % NTRs X NVoxels X Nsamples
        NTRs = size(current_data,1);
        NVoxels = size(current_data,2);
        Nsamples = size(current_data,3);
        current_data = reshape(current_data,NTRs*NVoxels,Nsamples); % NTRs*NVoxels X Nsamples
        Nsamples = size(current_data,2);
        Ntest = ceil(Nsamples*TestFraction);
        rndidx =  randperm(Nsamples); % random indices
        
        testidx = rndidx(1:Ntest);
        trainidx = rndidx(Ntest+1:end);

        TrainBatch_data(nc,ns) = {current_data(:,trainidx)}; % train data
        TestBatch_data(nc,ns) = {current_data(:,testidx)}; % test data
    end
end
TrainBatch.data = TrainBatch_data;
TrainBatch.subjects = cls.subjects;

TestBatch.data = TestBatch_data;
TestBatch.subjects = cls.subjects;
end