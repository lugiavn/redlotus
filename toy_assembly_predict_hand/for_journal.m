

figure(2);

for p=1:data.progress_level_num
    subplot(1, data.progress_level_num, p);
    imagesc(frame);
            imshow(frame);
    
    hold on;
            d = data.action_hand_positions(i).hands(p);
     plotcov2(d.mean', d.var / 5, ...
                'Color' , 'green', 'LineWidth', 4);
     hold off;
end


