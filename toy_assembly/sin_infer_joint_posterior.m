function the_joint = sin_infer_timestep_labels( sin, factorTables, symbol_name )
%SIN_INFER_JOINT_N_FRAME_LABELS Summary of this function goes here
%   Detailed explanation goes here

if isstr(symbol_name)
    symbol_id = sin.original_grammar.name2id.(symbol_name);
else
    symbol_id = symbol_name;
end

T = sin.params.T;

the_joint = zeros(T);

timestep_label_posterior = zeros(length(sin.nodes), T);

for i = find([sin.compiled_grammar.symbols.is_terminal] == 1)
    
    n = sin.nodes(i);
    s = sin.compiled_grammar_result.symbols(i);
    j = sin.compiled_grammar.symbols(i).original_symbol_id;

    if s.happen_prob == 0
        continue;
    end
    
    % compute the joint posterior of start and end
    joint = repmat(n.forward_phase.the_start.v', [1 sin.params.T]) .* factorTables.s{j} .* repmat(n.backward_phase.the_end.v, [sin.params.T 1]) .* triu(ones(T));
    joint = joint / sum(joint(:)) * s.happen_prob;
    
    % pool
    if sin.compiled_grammar.symbols(i).original_symbol_id == symbol_id
        the_joint = the_joint + joint;
    end
end




