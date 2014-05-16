
%% generate network
clear; clc;
T   = 100;
sin = sin_load_grammar_n_gen_network('grammar1.txt', T);
grammar = sin.compiled_grammar.original_grammar;

%% compute duration factor
durations = {};
for i=1:length(grammar.symbols)
    if grammar.symbols(i).is_terminal
        durations{i} = sin_gen_duration_table(grammar.symbols(i).params.duration_mean, grammar.symbols(i).params.duration_var, T);
    end
end

% compute detections factor
detections = {};
for i=[grammar.symbols.detector_id]
    if i > 0
        detections{i} = rand(T);
    end
end

% compute final factor tables
factorTables = {};
for i=1:length(grammar.symbols)
    if grammar.symbols(i).is_terminal
        factorTables{i} = detections{grammar.symbols(i).detector_id} .* durations{i} ;
    end
end

%% perform inference
sin = sin_perform_inference(sin, factorTables);
sin = sin_infer_timestep_labels(sin, factorTables);














