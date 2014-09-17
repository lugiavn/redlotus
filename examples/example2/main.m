
% consuct network
T   = 600;
sin = sin_load_grammar_n_gen_network('grammar1.txt', T);

% compute duration factor
durations  = sin_compute_durationFactors(sin.original_grammar, T);

% with some detection
detections     = {rand(T), rand(T), rand(T), rand(T), rand(T)};
detection_mean = [rand rand rand rand rand];

% compute final factor tables
factorTables.s = sin_combine_durations_n_detections(sin.original_grammar, durations, detections, detection_mean);
factorTables.start_prior = [0 0 0 1 2 3 4 5 3 1 zeros(1, T-10)];
factorTables.end_prior   = ones(1, T);

% perform inference
sin = sin_perform_inference(sin, factorTables);
subplot(2,2,1);
sin_plot_timing_distributions(sin, {'S', 'a', 'b', 'c', 'd', 'e'}, {'S'});

sin = sin_infer_timestep_labels(sin, factorTables);
subplot(2,2,2);
sin_plot_timesteplabel_distributions(sin);

%% for grammar2
sin2 = sin_load_grammar_n_gen_network('grammar2.txt', T);
durations2  = sin_compute_durationFactors(sin2.original_grammar, T);
factorTables.s = sin_combine_durations_n_detections(sin2.original_grammar, durations2, detections, detection_mean);

% should be the same as figure(1)
sin2 = sin_perform_inference(sin2, factorTables);
subplot(2,2,3);
sin_plot_timing_distributions(sin2, {'S', 'a', 'b', 'c', 'd', 'e'}, {'S'});

% should be the same as figure(2)
sin2 = sin_infer_timestep_labels(sin2, factorTables);
subplot(2,2,4);
sin_plot_timesteplabel_distributions(sin2);




