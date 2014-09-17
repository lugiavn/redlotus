

recorder = nx_record_figures_init(10, test.filename);
    
%% set up inference structure

T           = round ( time_scale * max([data.examples.length]) * 1.1);
sin         = sin_load_grammar_n_gen_network([data.path '/grammar.txt'], T);

observed_timestep = ones(1, T) * 1;
if 1
    sequence_length = test.length * time_scale;
    observed_timestep(sequence_length*0.25:sequence_length*0.75) = 0;
end

durations  = sin_compute_durationFactors_dualGaussian(data.grammar, T, time_scale);
% durations  = sin_compute_durationFactors(data.grammar, T, time_scale);
detections = {ones(T), ones(T), ones(T), ones(T), ones(T), ones(T)};

factorTables.start_prior = ones(1, T);
factorTables.end_prior   = ones(1, T);

factorTables.start_prior(end*0.2:end) = 0;

%% set up phyprop
if do_phyprops
    temp;
end

%% process

for timestep=1:T
    
    t = round(timestep / time_scale);
    if t > test.length
        break;
    end
    lastround = round((timestep + 1) / time_scale) > test.length;
    
    % update detection
    if 1
    if observed_timestep(timestep)
        % get reaching hand
        hands = test.handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand );
        
        for i=1:length(data.training.visualdetectors)
        if ~isnan(detections_result(i))
            
            offset_timestep = round(timestep + data.timing_offset * time_scale);
            if offset_timestep > 0 & offset_timestep < T
                detections{i}(offset_timestep,:) = detections_result(i);
            end
            
            if lastround
                detections{i}(offset_timestep+1:end,:) = 0;
            end
        end
        end
    end
    end
    
    % perform inference
    if mod(timestep, 1+inference_skip_rate) == 0 | lastround
        
        factorTables.s = sin_combine_durations_n_detections(data.grammar, durations, detections);
        sin = sin_perform_inference(sin, factorTables);
        
        if do_segmentation
            sin = sin_infer_timestep_labels(sin, factorTables);
        end
        
        % do phyprop
        if do_phyprops
            do_phyprop_predict
        end
        
        % viz
        viz_inference
        recorder = nx_record_figures_process(recorder);
        pause(0.5);
    end
    
    
end

recorder = nx_record_figures_terminate(recorder);





