function sin = sin_infer_timestep_labels( sin, factorTables )
%SIN_INFER_JOINT_N_FRAME_LABELS Summary of this function goes here
%   Detailed explanation goes here

T = sin.params.T;
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
    
    if sin.params.check_valid_data, assert(sin_check_valid_data(joint)); end;
    
	integral_joint = cumsum(cumsum(joint(:,end:-1:1), 2));
	integral_joint = integral_joint(:,end:-1:1);

    % compute the posterior of timestep label = compiled_grammar_symbol(i)
    p = zeros(1,T);
    for t=1:T-1
        p(t) = integral_joint(t,t+1);
    end

    timestep_label_posterior(i,:) = p;
end

% now compute for composition
timestep_label_posterior = compute_for_composition(timestep_label_posterior, sin, sin.compiled_grammar.starting);

% pool back into original grammar
sin.result.timestep_label_posterior = zeros(length(sin.result.symbols), T);
for i=1:length(sin.nodes)
    j = sin.compiled_grammar.symbols(i).original_symbol_id;
    sin.result.timestep_label_posterior(j,:) = sin.result.timestep_label_posterior(j,:) + timestep_label_posterior(i,:);
end

sin.compiled_grammar_result.timestep_label_posterior = timestep_label_posterior;

end

%% ------------------------------------------------------------------------------
function timestep_label_posterior = compute_for_composition(timestep_label_posterior, sin, id)
    if sin.compiled_grammar.symbols(id).is_terminal
        return;
    end
    
    timestep_label_posterior(id,:) = 0;
    
    for i=sin.compiled_grammar.symbols(id).prule.right
        timestep_label_posterior = compute_for_composition(timestep_label_posterior, sin, i);
        timestep_label_posterior(id,:) = timestep_label_posterior(id,:) + timestep_label_posterior(i,:);
    end
end



