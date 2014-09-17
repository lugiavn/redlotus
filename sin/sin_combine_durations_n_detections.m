function s_factorTables = sin_combine_durations_n_detections( original_grammar, durations, detections, detection_mean )
%SIN_COMBINE_DURATIONS_N_DETECTIONS Summary of this function goes here
%   Detailed explanation goes here

    s_factorTables = {};
    
    if exist('detection_mean')
    for i=1:length(detections)
        detections{i} = detections{i} / detection_mean(i);
    end
    end
    
    for i=1:length(original_grammar.symbols)
        if original_grammar.symbols(i).is_terminal
            d_id = original_grammar.symbols(i).params.detector_id;
            s_factorTables{i} = durations{i} .* detections{d_id};
        end
    end

end

