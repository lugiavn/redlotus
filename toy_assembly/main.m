
clc; close all; clear;

%% load dataset
disp 'Load dataset ...'
load_dataset;
clearvars -except data;

% choose training examples & testing examples
data.testing_ids  = randi([1 length(data.examples)]);
data.testing_ids  = 2;
data.training_ids = setdiff(1:length(data.examples), data.testing_ids);

%% train
disp 'Training ...'
do_training;
clearvars -except data;

%% testing
disp 'Testing ...'

test                = data.examples(data.testing_ids(1));
online_parsing      = 1;
do_segmentation     = 1;
time_scale          = 1 / 8;
inference_skip_rate = 50;

if online_parsing
    do_online_parsing;
else
    % skip everything & perform the final inference
    inference_skip_rate = inf; 
    do_online_parsing;
end


