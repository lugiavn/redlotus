function heatmap = particles_2_heatmap( particles , mapsize)
%PARTICLES_2_HEATMAP Summary of this function goes here
%   Detailed explanation goes here

    heatmap = zeros(mapsize(2), mapsize(1));
    
    particles = round(particles);
    
    for i=1:size(particles,1)
        try
        heatmap(particles(i,2),particles(i,1)) = heatmap(particles(i,2),particles(i,1)) + 1;
        end
    end
    
    heatmap = heatmap / size(particles,1);
end

