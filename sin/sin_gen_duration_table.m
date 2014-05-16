function duration_table = sin_gen_duration_table( duration_mean, duration_var, T )
%SIN_GET_NETWORK Summary of this function goes here
%   Detailed explanation goes here

    duration_vector = nxmakegaussian(T, duration_mean + 1, duration_var);
    duration_table  = zeros(T, T);
    
    for j=1:T
        duration_table(j,j:end) = duration_vector(1:T-j+1);
    end

end