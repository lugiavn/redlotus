function durations = sin_compute_durationFactors_dualGaussian( original_grammar, T, time_scale )
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
    
    durations{i} = 0.9 * sin_gen_duration_table(m, v, T) + 0.09 * sin_gen_duration_table(m, 4 * v, T) + 0.01 * sin_gen_duration_table(m, 16 * v, T);
    
end
end

end

