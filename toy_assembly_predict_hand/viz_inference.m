% clf;

%% viz video frame

try
    f = read(vid, t);
catch
    vid = VideoReader([data.path '/' test.filename]);
    f = read(vid, t);
end
if do_phyprops, nx_figure(2); end;
subplot(2, 3, 1);
imshow(f);
text(50, 450, 'Bin 1', 'BackgroundColor',[.7 .9 .7]);
text(50+120, 450, 'Bin 2', 'BackgroundColor',[.7 .9 .7]);
text(50+120*2, 450, 'Bin 3', 'BackgroundColor',[.7 .9 .7]);
text(50+120*3, 450, 'Bin 4', 'BackgroundColor',[.7 .9 .7]);
text(50+120*4, 450, 'Bin 5', 'BackgroundColor',[.7 .9 .7]);    
if ~isnan(hands(1))
    nxcircle2(hands(1), hands(2), 50, [1 1 1]);
end
if ~isnan(hands(3))
    nxcircle2(hands(3), hands(4), 50, [1 1 1]);
end
if ~isnan(reaching_hand(1))
    nxcircle2(reaching_hand(1), reaching_hand(2), 50, [1 1 1]);
end
text(0, 0, ['Present [Current timestep: ' num2str(timestep) ']'], 'BackgroundColor',[.9 .2 .2]); 

% viz phyprops
if do_phyprops
    i = 9;
    for offsetahead=round(prediction_times * data.framerate * time_scale)
        try
            f = read(vid, round((timestep+offsetahead) / time_scale));
        catch
            break;
        end
        h = particles_2_heatmap(phyprops{timestep+offsetahead}, [ 640  480 ]);
        nx_figure(2)
        subplot(4, 4, i); i = i + 1;
        imshow(f);
        hold on;
        imshow(100000 * imfilter(h, fspecial('gaussian',[50 50], 10),'same'));
        alpha(0.5);
        text(0, 0, ['Future (+' num2str(offsetahead / time_scale / data.framerate) 's) and prediction'], 'BackgroundColor',[.9 .2 .2]); 
        hold off;
    end
end


%% viz detection
% subplot(4, 3, [2 3]);
% plot(0);
% % semilogy(0);
% hold on;
% for i=1:5
%     plot(1:T, detections{i}(:,end), 'color', nxtocolor(i));
% end
% plot([timestep timestep], [0 1]);
% legend ( {'', 'Bin1 Reaching', 'Bin2 Reaching', 'Bin3 Reaching', 'Bin4 Reaching', 'Bin5 Reaching'} );
% hold off;

%% viz timings
% subplot(4, 3, [5 6]);
subplot(2, 3, [2 3])
start_names = {'body1', 'wheel1', 'nose_c1', 'wing_a1', 'tail_b1', 'sticker'};
start_names = {'body1', 'body2', 'body3', 'body4', ...
    'nose_ab1', 'nose_ab2', 'nose_ab3','nose_ab4', ...
    'wing_a1', 'wing_a2', 'wing_a3', ...
    'tail_a1','tail_a2','tail_a3', ...
    'sticker'};
end_names   = {};
ts = t + [0 prediction_times] * data.framerate - data.timing_offset;
for i=1:length(test.label.actions)
    if sum((test.label.actions(i).start <= ts) .* (test.label.actions(i).end >= ts)) > 0
        try
%             start_names{end+1} = test.label.actions(i).name;
        catch
        end
    end
end
% start_names = unique(start_names);
sin_plot_timing_distributions(sin, start_names, end_names);

% groundtruth mark
hold on;
plot([timestep timestep], [0 1]);
for a=test.label.actions
if ismember(a.name, start_names)
    id = data.grammar.name2id.(a.name);
    plot(a.start  * time_scale, 0.1, 'color', 'r', 'MarkerFaceColor', nxtocolor(id), 'Marker', 'v', 'MarkerSize', 10);
end
end
hold off;

% %% viz timestep label
% if do_segmentation
% subplot(4, 3, [8 9 11 12]);
% plot(0);
% sin_plot_timesteplabel_distributions(sin, {'S', 'Body', 'Wheel', 'Nose_AB', 'Nose_C', 'Wing_A', 'Tail_A', 'Wing_B', 'Tail_B', 'Wing_C', 'Tail_C', 'sticker'});
% end
        