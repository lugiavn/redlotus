
close all; clear;

%% load dataset
disp 'Load dataset ...'
load_dataset;
clearvars -except data;

% choose training examples & testing examples
data.testing_ids  = randi([1 length(data.examples)]);
data.testing_ids  = 6; % 20 is wrong
data.training_ids = setdiff(1:length(data.examples), data.testing_ids);

%% train
disp 'Training ...'
do_training;
do_training_hands;
clearvars -except data;

%% testing
disp 'Testing ...'

test                = data.examples(data.testing_ids(1));
do_segmentation     = 0;
online_parsing      = 1;
do_phyprops         = 1;
time_scale          = 1 / 6;
inference_skip_rate = 1;

prediction_times    = [0.5 2 5 10 30];
% prediction_times    =  -[0.5 2 5 10 30];
% prediction_times    = -[test.length * [0.25 0.3 0.4 0.5 0.6 0.7 0.75] / data.framerate];

if online_parsing
    do_online_parsing;
else
    % skip everything & perform the final inference
    inference_skip_rate = inf; 
    do_online_parsing;
end


