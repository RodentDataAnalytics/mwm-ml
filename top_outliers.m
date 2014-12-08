function out = top_outliers( X, k, n, standardize )
%REMOVE_OUTLIERS Summary of this function goes here
%   Detailed explanation goes here
    out = [];
    dk = [];
    dmin = 0;
    
    if standardize
        means = repmat(mean(X), length(X), 1);
        stddev = repmat(std(X), length(X), 1);
        X = (X - means) ./ stddev;        
    end
    
    fprintf('Cheking for outliers...\n');
    
    sz = size(X, 1);
    fprintf('0.0% '); 
    
    q = floor(sz/1000);
        
    for i = 1:sz
        % indices of neighbourhood of current element
        neigh = [];
        d = [];
        dmax = 0;
        for j = 1:sz
            if i == j
                continue;
            end
            neigh = [neigh, j];
            d = [d, sqrt( sum((X(i, :) - X(j, :)).^2) )];
            [d, ord] = sort(d);
            nn = length(d);
            dmax = d(ord(end));
            ord = ord(1:min(k, nn));
            neigh = neigh(ord);
            d = d(ord);
            if nn == k && dmin > dmax  
                break;
            end                      
        end
        [dk, ord] = sort([dk, dmax], 'descend');
        ord = ord(1:min(n, length(ord)));
        out = [out, i];
        out = out(ord);
        if length(out) == n
            dmin = dk(end);
        end        
        dk = dk(ord);    
        
        if mod(i, q) == 0
            val = i/sz*100.;
            if val < 10.
                fprintf('\b\b\b\b\b%03.1f%% ', val);
            else
                fprintf('\b\b\b\b\b%04.1f%%', val);
            end    
        end            
    end
    fprintf('\b\b\b\b\bDone.\n');
end