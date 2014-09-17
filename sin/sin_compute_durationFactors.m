function durations = sin_compute_durationFactors( original_grammar, T, time_scale )
%SIN_COMPUTE_DURATIONFACTORS Summary of this function goes here
%   Detailed explanation goes here

if ~exist('time_scale')
    time_scale = 1;
end

durations = {};

for i=1:length(original_grammar.symbols)
if original_grammar.symbols(i).is_terminal

    m = original_grammar.symbols(i).params.duration_mean * time_scale;
    v = original_grammar.symbols(i).params.duration_var  * time_scale^2;
    
    durations{i} = sin_gen_duration_table(m, v, T);
end
end

end

