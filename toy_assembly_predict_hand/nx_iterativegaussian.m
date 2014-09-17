function [data newmean newvar] = nx_iterativegaussian( data, keeping_percentages )
%NX_ITERATIVEGAUSSIAN Summary of this function goes here
%   Detailed explanation goes here

    for p=keeping_percentages
        
        newmean         = mean(data);
        newvar          = cov(data);
        x               = mvnpdf(data, newmean, newvar);
        [~, sorted_id]  = sort(x, 1, 'descend');
        data            = data(sorted_id(1:round(end * p)),:);
        
    end

    newmean	= mean(data);
    newvar 	= cov(data);
end

