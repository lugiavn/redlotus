% clf;

%% viz video frame
try
    f = read(vid, t);
catch
    vid = VideoReader([data.path '/' test.filename]);
    f = read(vid, t);
end
subplot(4, 3, [1 4]);
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

%% viz detection
subplot(4, 3, [2 3]);
plot(0);
% semilogy(0);
hold on;
for i=1:5
    plot(1:T, detections{i}(:,end), 'color', nxtocolor(i));
end
plot([timestep timestep], [0 1]);
legend ( {'', 'Bin1 Reaching', 'Bin2 Reaching', 'Bin3 Reaching', 'Bin4 Reaching', 'Bin5 Reaching'} );
hold off;

%% viz timings
subplot(4, 3, [5 6]);
start_names = {'body1', 'wheel1', 'nose_ab1', 'wing_b1', 'tail_b1', 'sticker'};
end_names   = {};
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

%% viz timestep label
if do_segmentation
    subplot(4, 3, [8 9 11 12]);
    plot(0);
    sin_plot_timesteplabel_distributions(sin, {'S', 'Body', 'Wheel', 'Nose_AB', 'Nose_C', 'Wing_A', 'Tail_A', 'Wing_B', 'Tail_B', 'Wing_C', 'Tail_C', 'sticker'});
end
        