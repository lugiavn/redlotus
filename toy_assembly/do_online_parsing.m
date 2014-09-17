

%% set up inference structure

T           = round ( time_scale * max([data.examples.length]) * 1.1);
sin         = sin_load_grammar_n_gen_network([data.path '/grammar.txt'], T);

durations  = sin_compute_durationFactors(data.grammar, T, time_scale);
detections = {ones(T), ones(T), ones(T), ones(T), ones(T), ones(T)};

factorTables.start_prior = ones(1, T);
factorTables.end_prior   = ones(1, T);

factorTables.start_prior(end*0.2:end) = 0;


%% process

for timestep=1:99999999
    
    t = round(timestep / time_scale);
    if t > test.length
        break;
    end
    lastround = round((timestep + 1) / time_scale) > test.length;
    
    % update detection
    if 1
        % get reaching hand
        hands = test.handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand );
        
        for i=1:length(data.training.visualdetectors)
        if ~isnan(detections_result(i))
            detections{i}(timestep,:) = detections_result(i);

            if lastround
                detections{i}(timestep+1:end,:) = 0;
            end
        end
        end
    end
    
    % perform inference
    if mod(timestep, inference_skip_rate) == 1 | lastround
        
        factorTables.s = sin_combine_durations_n_detections(data.grammar, durations, detections);
        sin = sin_perform_inference(sin, factorTables);
        
        if do_segmentation
            sin = sin_infer_timestep_labels(sin, factorTables);
        end
        
        % viz
        viz_inference
        pause(0.2);
    end
    
    
end







