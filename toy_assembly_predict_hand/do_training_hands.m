

%% compute active hand observed position
for i=1:length(data.examples)

    for t=1:data.examples(i).length

        active_hand     = get_reaching_hand( data.examples(i).handsdetections(t,:) );
        active_hand_cov = ones(2) * 1000;
        
        data.examples(i).active_hand_obv(t).mean = active_hand;
        data.examples(i).active_hand_obv(t).var  = active_hand_cov;
    end
end

%% train the action-hand positions


for i=1:length(data.grammar.symbols)
if data.grammar.symbols(i).is_terminal

    data.action_hand_positions(i).hands = struct;

    for p=1:data.progress_level_num

        data.action_hand_positions(i).hands(p).data = [];
        data.action_hand_positions(i).hands(p).mean = nan;
        data.action_hand_positions(i).hands(p).var  = nan;

    end
end
end

%% collect data
for i=1:length(data.examples)
for a=data.examples(i).label.actions
    assert(a.end - a.start > 40);
    a_id = data.grammar.name2id.(a.name);

    for p=1:data.progress_level_num

        tt = nx_linear_scale_to_range(p, 1, data.progress_level_num, a.start+data.timing_offset, a.end+data.timing_offset);
        tt = round(tt);

        for t=max(1,tt-5):1:min(data.examples(i).length, tt+5)
            h = data.examples(i).active_hand_obv(t).mean;

            if ~isnan(h)
                data.action_hand_positions(a_id).hands(p).data(end+1,:) = h;
            end
        end
    end
end
end

%% compute mean & var

for i=1:length(data.grammar.symbols)
if data.grammar.symbols(i).is_terminal
if ~strcmp(data.grammar.symbols(i).name, 'null')
    for p=1:data.progress_level_num
        
        % refine data, remove outliners
        d = data.action_hand_positions(i).hands(p);
        [d.data d.mean d.var] = nx_iterativegaussian(d.data, [0.9 0.9 0.9 0.9 0.9]);
        
        data.action_hand_positions(i).hands(p) = d;

        % special data structure to use later
        data.prior_phyprops{i}(p) = d;
    end
    
    % viz
    if 0
        disp(data.grammar.symbols(i).name)
        try
            imagesc(frame);
        catch
            vid = VideoReader([data.path data.examples(1).filename]);
            frame = read(vid, 10);
            imagesc(frame);
        end

        hold on;
        for p=1:data.progress_level_num
            d = data.action_hand_positions(i).hands(p);
%             plot(d.data(:,1), d.data(:,2), '*', 'Color' , ones(1,3) * p/data.progress_level_num);
            plotcov2(d.mean', d.var / 10, ...
                'Color' , ones(1,3) * p/data.progress_level_num);
            
        end
        hold off;
        for_journal
        pause
    end
end
end
end




