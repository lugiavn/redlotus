
% consuct network
T   = 200;
sin = sin_load_grammar_n_gen_network('grammar.txt', T);

% compute duration factor
durations      = sin_compute_durationFactors(sin.original_grammar, T);

% no detection
detections     = {ones(T), ones(T), ones(T), ones(T), ones(T), ones(T)};
detection_mean = [1 1 1 1 1 1];

% compute final factor tables
factorTables.s = sin_combine_durations_n_detections(sin.original_grammar, durations, detections, detection_mean);
factorTables.start_prior = [0 0 0 1 2 3 4 5 3 1 zeros(1, T-10)];
factorTables.end_prior   = ones(1, T);

% perform inference
sin = sin_perform_inference(sin, factorTables);
subplot(2,2,1);
sin_plot_timing_distributions(sin, {'S', 'a1', 'a2', 'c1', 'c2'}, {'S'});

sin = sin_infer_timestep_labels(sin, factorTables);
subplot(2,2,2);
sin_plot_timesteplabel_distributions(sin);

%% with some detection

detections     = {rand(T), rand(T), rand(T), rand(T), rand(T), rand(T)};
detection_mean = [rand rand rand rand rand rand/100];

% compute final factor tables
factorTables.s = sin_combine_durations_n_detections(sin.original_grammar, durations, detections, detection_mean);
factorTables.start_prior = [0 0 0 1 2 3 4 5 3 1 zeros(1, T-10)];
factorTables.end_prior   = ones(1, T);

% perform inference
sin = sin_perform_inference(sin, factorTables);
subplot(2,2,3);
sin_plot_timing_distributions(sin, {'S', 'a1', 'a2', 'c1', 'c2'}, {'S'});

sin = sin_infer_timestep_labels(sin, factorTables);
subplot(2,2,4);
sin_plot_timesteplabel_distributions(sin);








