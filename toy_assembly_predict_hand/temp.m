

K          = struct;

K.F        = repmat([1 0 1 0; 0 1 0 1; 0 0 1 0 ; 0 0 0 1], [1 1 T]); % transition matrix
K.H        = repmat([1 0 0 0; 0 1 0 0], [1 1 T]); % observation matrix

K.Q        = repmat(eye(4) * 400, [1 1 T]); % state noise
K.y        = repmat([300 100]', [1 T]); % observation
K.R        = repmat([400000 0; 0 8000], [1 1 T]); % obv noise

K.y_prior = K.y;
K.R_prior = K.R;

% obv
for timestep=1:T
    
    % compute t
    t = round(timestep / time_scale);
    if t > test.length
        break;
    end
    
    % compute hands
    hands         = test.handsdetections(t,:);
    reaching_hand = get_reaching_hand( hands );
    if isnan(reaching_hand(1))
        continue;
    end
    hand_is_reaching = reaching_hand(2) > 250;
    
    % mid point
    if ~hand_is_reaching & sum(isnan(hands)) == 0
        reaching_hand(1) = ( hands(1) + hands(3))/2;
        reaching_hand(2) = ( hands(2) + hands(4))/2;
    end
    
    % update
    K.R(:,:,timestep) = [100 0; 0 100];
    if ~hand_is_reaching
        K.R(:,:,timestep) = [2000 0; 0 200];
    end
    K.y(:,timestep)   = reaching_hand;
end

% Kalman
[K.xsmooth, K.Vsmooth] = kalman_smoother(K.y, K.F, K.H, K.Q, K.R, [300 200 0 0]', eye(4) * 10e6, 'model', [1:T]);

% for timestep=1:T
% try
%     imagesc(frame);
% catch
%     vid = VideoReader([data.path data.examples(1).filename]);
%     frame = read(vid, 10);
%     imagesc(frame);
% end
% hold on;
% plot(K.xsmooth( 1, timestep), K.xsmooth( 2, timestep), '*');
% plotgauss2d(K.xsmooth(1:2,timestep), K.Vsmooth(1:2,1:2,timestep));
% plot(K.y( 1, timestep), K.y( 2, timestep), '*r');
% hold off;
% pause(0.2);
% end







