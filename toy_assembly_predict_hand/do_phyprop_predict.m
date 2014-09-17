

y = K.y_prior;
R = K.R_prior;
% y(:,1:timestep) = K.y(:,1:timestep);
% R(:,:,1:timestep) = K.R(:,:,1:timestep);

for t123=1:timestep
    if observed_timestep(t123)
        y(:,t123) = K.y(:,t123);
        R(:,:,t123) = K.R(:,:,t123);
    end
end

% Just Kalman
[K.xsmooth, K.Vsmooth] = kalman_smoother(y, K.F, K.H, K.Q, R, [300 200 0 0]', eye(4) * 10e6, 'model', [1:T]);

for t53=1:T
    obv_phyprops(t53).mean = K.xsmooth(1:2,t53);
    obv_phyprops(t53).var  = K.Vsmooth(1:2,1:2,t53);
end

phyprops = sin_predict_phyprops( sin, factorTables, data.prior_phyprops, obv_phyprops, round(prediction_times * data.framerate * time_scale )+ timestep);

gogo = 1;

