function phyprop = sin_predict_phyprops( sin, factorTables, prior_phyprops, obv_phyprops, ts)
%PREDICT_PHYPROP Summary of this function goes here
%   Detailed explanation goes here


    phyprop = {};
    pcount  = [];
    for timestep=ts
            phyprop{timestep} = zeros(100000,2);
            pcount(timestep)  = 0;
    end
    
    progress_level_num = length(prior_phyprops{end});

    %% get the list of (compiled-grammar-)action to sample

    action_id_to_sample = [];
    
    for i=1:length(sin.compiled_grammar.symbols)
    if sin.compiled_grammar.symbols(i).is_terminal
        if isfield(sin.compiled_grammar_result, 'timestep_label_posterior')
            if sum(sin.compiled_grammar_result.timestep_label_posterior(i, ts)) > 0.0001
                action_id_to_sample(end+1) = i;
            end
        else
            for t=ts
            if sum(sin.compiled_grammar_result.symbols(i).the_start(1:min(end,t))) > 0.0001 & ...
                    sum(sin.compiled_grammar_result.symbols(i).the_end(t:end)) > 0.0001
                action_id_to_sample(end+1) = i;
                break;
            end
            end
        end
    end
    end
    
    
    
    %% sample each action
    num = 1000;
    for a_id = action_id_to_sample
    
        n = sin.nodes(a_id);
        s = sin.compiled_grammar_result.symbols(a_id);
        j = sin.compiled_grammar.symbols(a_id).original_symbol_id;
        
        % compute the joint
        joint = repmat(n.forward_phase.the_start.v', [1 sin.params.T]) .* factorTables.s{j} .* repmat(n.backward_phase.the_end.v, [sin.params.T 1]) .* triu(ones(sin.params.T));
        joint = joint / sum(joint(:)) * s.happen_prob;
    
        % sampling
        for i=randsample(length(joint(:)), round(s.happen_prob * num), true, joint(:))'
            
            % sample the start and end
            a_end   = floor(i / size(joint,1)) + rand - 0.5;
            a_start = mod(i, size(joint,1))    + rand - 0.5;
%             disp([a_start a_end]);

            % time
            for timestep=ts
                if timestep < a_start | timestep > a_end
                    continue;
                end

                q    = nx_linear_scale_to_range(timestep, a_start, a_end + 0.001, 1, progress_level_num );
                w(2) = q - floor(q);
                w(1) = 1 - w(2);
                q    = floor(q);

                m2 = w(1) * prior_phyprops{j}(q).mean' + w(2) * prior_phyprops{j}(q+1).mean';
                v2 = w(1) * prior_phyprops{j}(q).var + w(2) * prior_phyprops{j}(q+1).var;
                
                m1 = obv_phyprops(timestep).mean;
                v1 = obv_phyprops(timestep).var;
                
                v = inv(inv(v1) + inv(v2));
                m = v * (inv(v1) * m1 + inv(v2) * m2);
                
                m = m1;
                v = v1;
                
                phyprop{timestep}([1:100] + pcount(timestep),:) = mvnrnd(m, v, 100);
                pcount(timestep) = pcount(timestep) + 100;
            end
        end
    end
    
    %% done
    
    for timestep=ts
        phyprop{timestep} = phyprop{timestep}(1:pcount(timestep),:);
    end
end

