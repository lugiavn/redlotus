function sin_plot_timesteplabel_distributions( sin, names )
%SIN_PLOT_TIMESTEPLABEL_DISTRIBUTIONS Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('names')
        names = {};
        for i=setdiff(1:length(sin.original_grammar.symbols), sin.original_grammar.dummy_ids)
            names{end+1} = sin.original_grammar.symbols(i).name;
        end
    end

    % get id
    ids = [];
    for i=1:length(names)
        ids(end+1) = sin.original_grammar.name2id.(names{i});
    end

    % plot
    imagesc(sin.result.timestep_label_posterior(ids, :)); colormap gray;
    set(gca,'YTick',[]);
    
    % legend
    hold on;
    for i=1:length(names)
        text(-1, i, names{i}, 'HorizontalAlignment','right', 'BackgroundColor',[.7 .9 .7]);
    end
    hold off;
end

