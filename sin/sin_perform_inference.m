function sin = sin_perform_inference( sin, factorTables )
%SIN_PERFORM_INFERENCE Summary of this function goes here
%   Detailed explanation goes here

    root = sin.compiled_grammar.starting;
    assert(root == 1);
    
    % check factor Tables valid
    if sin.params.check_valid_data
        for i=1:length(factorTables.s)
            assert(sin_check_valid_data(factorTables.s{i}));
        end
    end
    
    % perform forward phase, recursively from root
    sin.nodes(root).forward_phase.the_start.v   = factorTables.start_prior;
    sin.nodes(root).forward_phase.the_start.exp = 0;
    sin = perform_forward(sin, factorTables, root);
    
    % perform backward phase, recursively from root
    sin.nodes(root).backward_phase.the_end.v   = factorTables.end_prior;
    sin.nodes(root).backward_phase.the_end.exp = 0;
    sin = perform_backward(sin, factorTables, root);
    
    % compute the posterior
    sin.compiled_grammar_result.symbols(root).happen_prob = 1;
    sin = sin_compute_exist_prob(sin, root);
    sin = compute_posterior(sin);
    
    % map result to original grammar
    sin = compute_result_original_grammar(sin);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sin = perform_forward(sin, factorTables, id)
    n = sin.nodes(id);
    s = sin.compiled_grammar.symbols(id);
    
    % --------- Primitive action ----------
    if s.is_terminal
        
        t   = n.forward_phase.the_start;
        t.v = sum(repmat(t.v', [1 sin.params.T]) .* factorTables.s{s.original_symbol_id}, 1);
        t   = norm_t(t);
        
        n.forward_phase.the_end = t;
        
        
    % --------- OR composition ------------- 
    elseif s.prule.or_rule
        
        % recursive on components
        t = n.forward_phase.the_start;
        for i=s.prule.right
            sin.nodes(i).forward_phase.the_start = t;
            sin = perform_forward(sin, factorTables, i);
        end
        
        % the end = weighted sum of component ends
        t.v(:) = 0;
        t.exp  = 0;
        j      = 0;
        for i=s.prule.right
            j    = j + 1;
            t2   = sin.nodes(i).forward_phase.the_end;
            t2.v = t2.v * s.prule.or_probs(j);
            t    = x_sum(t, t2);
        end
        n.forward_phase.the_end = t;
        
    % --------- AND composition -------------    
    else
        
        % recursive on components
        t = n.forward_phase.the_start;
        
        for i=s.prule.right
            sin.nodes(i).forward_phase.the_start = t;
            sin = perform_forward(sin, factorTables, i);
            t = sin.nodes(i).forward_phase.the_end;
        end
        
        % the end = the end of last component
        n.forward_phase.the_end = t;
    end
    
    % save
    if sin.params.check_valid_data
        assert(sin_check_valid_data(n.forward_phase.the_end.v));
    end
    sin.nodes(id) = n;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sin = perform_backward(sin, factorTables, id)
    n = sin.nodes(id);
    s = sin.compiled_grammar.symbols(id);
    
    % --------- Primitive action ----------
    if s.is_terminal
        
        t = n.backward_phase.the_end;
        t.v = sum(repmat(t.v, [sin.params.T 1]) .* factorTables.s{s.original_symbol_id}, 2)';
        t   = norm_t(t);
        
        n.backward_phase.the_start = t;
        
        
    % --------- OR composition ------------- 
    elseif s.prule.or_rule
        
        % recursive on components
        t = n.backward_phase.the_end;
        for i=s.prule.right
            sin.nodes(i).backward_phase.the_end = t;
            sin = perform_backward(sin, factorTables, i);
        end
        
        % the end = weighted sum of component ends
        t.v(:) = 0;
        t.exp  = 0;
        j      = 0;
        for i=s.prule.right
            j    = j + 1;
            t2   = sin.nodes(i).backward_phase.the_start;
            t2.v = t2.v * s.prule.or_probs(j);
            t    = x_sum(t, t2);
        end
        n.backward_phase.the_start = t;
        
    % --------- AND composition -------------    
    else
        
        % recursive on components
        t = n.backward_phase.the_end;
        
        for i=s.prule.right(end:-1:1)
            sin.nodes(i).backward_phase.the_end = t;
            sin = perform_backward(sin, factorTables, i);
            t = sin.nodes(i).backward_phase.the_start;
        end
        
        % the start = the start of 1st component
        n.backward_phase.the_start = t;
    end
    
    % save
    if sin.params.check_valid_data
        assert(sin_check_valid_data(n.backward_phase.the_start.v));
    end
    sin.nodes(id) = n;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sin = compute_posterior(sin)
    
    
    % multiply forward & backward message
    for i=1:length(sin.nodes)
        
        n = sin.nodes(i);
        
        t = x_mul(n.forward_phase.the_start, n.backward_phase.the_start);
        if sin.params.check_valid_data, assert(sin_check_valid_data(t.v)); end;
        
        sin.compiled_grammar_result.symbols(i).the_start = t.v * sin.compiled_grammar_result.symbols(i).happen_prob;
        
        t = x_mul(n.forward_phase.the_end, n.backward_phase.the_end);
        if sin.params.check_valid_data, assert(sin_check_valid_data(t.v)); end;

        sin.compiled_grammar_result.symbols(i).the_end = t.v * sin.compiled_grammar_result.symbols(i).happen_prob;
    end
    
end

function sin = sin_compute_exist_prob(sin, id)

    n = sin.nodes(id);
    s = sin.compiled_grammar.symbols(id);
    
    if s.is_terminal
        return;
    end
    
    if s.prule.or_rule
        
        probs = [];
        exps  = [];
        
        for i=s.prule.right
            n2           = sin.nodes(i);
            probs(end+1) = sum(n2.forward_phase.the_end.v .* n2.backward_phase.the_end.v);
            exps(end+1)  = n2.forward_phase.the_end.exp;
        end
        
        exps = exps + log(s.prule.or_probs);
        exps = exps - max(exps);
        for i=1:length(probs)
            probs(i) = probs(i) * exp(exps(i));
        end
        
        probs = probs / sum(probs) * sin.compiled_grammar_result.symbols(id).happen_prob;
        
        if sin.params.check_valid_data, assert(sin_check_valid_data(probs)); end;
        
        for i=s.prule.right
            sin.compiled_grammar_result.symbols(i).happen_prob = probs(1);
            probs(1) = [];
            sin = sin_compute_exist_prob(sin, i);
        end
        
    else
        for i=s.prule.right
            sin.compiled_grammar_result.symbols(i).happen_prob = sin.compiled_grammar_result.symbols(id).happen_prob;
            sin = sin_compute_exist_prob(sin, i);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sin = compute_result_original_grammar(sin)
    
    for i=1:length(sin.result.symbols)
        sin.result.symbols(i).the_start(:) = 0;
        sin.result.symbols(i).the_end(:)   = 0;
        sin.result.symbols(i).happen_prob  = 0;
    end
    
    for i=1:length(sin.nodes)
       
        j = sin.compiled_grammar.symbols(i).original_symbol_id;
        
        sin.result.symbols(j).the_start = sin.result.symbols(j).the_start + ...
            sin.compiled_grammar_result.symbols(i).the_start;
        
        sin.result.symbols(j).the_end = sin.result.symbols(j).the_end + ...
            sin.compiled_grammar_result.symbols(i).the_end;
        
        sin.result.symbols(j).happen_prob  = sin.result.symbols(j).happen_prob  + ...
            sin.compiled_grammar_result.symbols(i).happen_prob ;
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = x_sum(b, c)
    
    a.exp = max(b.exp, c.exp);
    a.v   = b.v * exp(b.exp - a.exp) + c.v * exp(c.exp - a.exp);
    
    a = norm_t(a);
end

function a = x_mul(b, c)

    a.exp = b.exp + c.exp;
    a.v   = b.v .* c.v;
    
    a = norm_t(a);
end

function a = norm_t(a)

    if sum(a.v) == 0
        a.v(:) = 0;
        a.exp  = 0;
    else
        a.exp = a.exp + log(sum(a.v));
        a.v   = a.v / sum(a.v);
    end
end




