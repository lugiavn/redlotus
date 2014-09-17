
data.training = struct;

viz_detection = 0;

%% train duration
for i=data.training_ids
for a=data.examples(i).label.actions
    if a.start > 0 & a.end > a.start
        symbolid = data.grammar.name2id.(a.name);
        try
            data.training.durations{symbolid}.data(end+1) = a.end - a.start + 1;
        catch
            data.training.durations{symbolid}.data        = a.end - a.start + 1;
        end
    end
end
end

for i=1:length(data.training.durations)
    if ~isempty(data.training.durations{i}) & ~isempty(data.training.durations{i}.data)
        data.training.durations{i}.mean = mean(data.training.durations{i}.data);
        data.training.durations{i}.var  = var(data.training.durations{i}.data);
    end
end

% update grammar
for i=1:length(data.training.durations)
    if ~isempty(data.training.durations{i}) & ~isempty(data.training.durations{i}.data)

        data.grammar.symbols(i).params.duration_mean = data.training.durations{i}.mean;
        data.grammar.symbols(i).params.duration_var  = max(300, data.training.durations{i}.var);
    end
end

%% train detection

% save hand positions at action start
for i=data.training_ids
for a=data.examples(i).label.actions
if a.start > 0 & a.end > a.start
    symbolid = data.grammar.name2id.(a.name);

    for t=a.start-8:1:a.start+8

        % find reaching hand position
        hands = data.examples(i).handsdetections(t,:);
        [ hands  missing_detections ] = get_reaching_hand( hands );
        if isnan(hands(1)) | hands(2) < 250
            continue;
        end

        % save
        detector_id = data.grammar.symbols(symbolid).params.detector_id;
        try
            data.training.visualdetectors{detector_id}.data(end+1,:) = hands;
        catch
            data.training.visualdetectors{detector_id}.data          = hands;
        end
    end
end
end
end

% traing each detector (for each bin)
for i=1:length(data.training.visualdetectors)
    
    % train
    if ~isempty(data.training.visualdetectors{i}) & ~isempty(data.training.visualdetectors{i}.data)
        data.training.visualdetectors{i}.mean = mean(data.training.visualdetectors{i}.data);
        data.training.visualdetectors{i}.var  = var(data.training.visualdetectors{i}.data) * 1;
    end
    
    % check
    v = mvnpdf(data.training.visualdetectors{i}.data, ...
        data.training.visualdetectors{i}.mean, data.training.visualdetectors{i}.var);
    
    % remove 5% worst
    [~, good_ids] = sort(v);
    good_ids = good_ids(round(length(good_ids) * 0.05):end);
    
    % viz training examples
    if viz_detection
        imagesc(zeros(480, 640));
        hold on;
        plot(data.training.visualdetectors{i}.data(good_ids,1), data.training.visualdetectors{i}.data(good_ids,2), '*');
        hold off;
        pause;
    end
    
    % retrain
    if ~isempty(data.training.visualdetectors{i}) & ~isempty(data.training.visualdetectors{i}.data)
        data.training.visualdetectors{i}.mean = mean(data.training.visualdetectors{i}.data(good_ids,:));
        data.training.visualdetectors{i}.var  = var(data.training.visualdetectors{i}.data(good_ids,:)) * 4;
    end
end

% calculate detection score 
for i=data.training_ids
    
    sequence_length = size(data.examples(i).handsdetections, 1);
    T               = (sequence_length / 5);
    
    for j=1:length(data.training.visualdetectors)
        data.examples(i).test.detection.result{j} = nan(round(T));
    end
        
    for t2=1:T
    	
        t = round(t2 * 5);
        
        % get reaching hand
        hands = data.examples(i).handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand , 1);
        
        for j=1:length(data.training.visualdetectors)
        if ~isnan(detections_result(j))
            data.examples(i).test.detection.result{j}(t2,:) = detections_result(j);
        end
        end
    end
end

% calculate mean detections
for j=1:length(data.training.visualdetectors)
     
    v = [];
    
    for i=data.training_ids
        v = [v; data.examples(i).test.detection.result{j}(:)];
    end
     
    v(~(v > 0)) = 0;
    data.training.visualdetectors{j}.mean_detection_score = mean(v) / 2;
    
end





