function sin_plot_timing_distributions( sin, start_names, end_names, scale_max_to_happen_prob )
%SIN_PLOT_TIMING_DISTRIBUTIONS Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('scale_max_to_happen_prob')
        scale_max_to_happen_prob = 1;
    end

    cla;
    hold on;
    
    names  = [start_names, end_names];
    starts = [ones(1, length(start_names)) zeros(1, length(end_names))];

    for i=1:length(names)
        
        id = sin.original_grammar.name2id.(names{i});
        
        d = sin.result.symbols(id).the_start;
        if ~starts(i)
            d = sin.result.symbols(id).the_end;
        end
        if scale_max_to_happen_prob
            d = d / max(10e-200, max(d));
            d = d * sin.result.symbols(id).happen_prob;
        end
        
        cid = sum(names{i});
        
        plot(1:sin.params.T, d, 'color', nxtocolor(id), 'LineWidth', nxifelse(mod(cid,2) == 0, 3, 1), 'LineStyle', nxifelse(mod(cid,2) == 0, '--', '-'));
    end
    
    % legend
    for i=1:length(names)
        if starts(i)
            names{i} = [names{i} ' start'];
        else
            names{i} = [names{i} ' end'];
        end
    end
    l = legend(names);
    set(l, 'Interpreter', 'none');
    hold off;
end

