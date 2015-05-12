function [ id, trial, pts ] = read_trajectory( fn )
%READ_TRAJECTORY Reads a trajectory from a file (native Ethovision format
%supported)
    if ~exist(fn, 'file')
        error('Non-existent file');
    end
    
    % use a 3rd party function to read the file; matlab's csvread is a complete joke
    data = robustcsvread(fn);
    err = 0;
    pts = [];
      
    %%
    %% parse the file
    %%
    
    % look for beggining of trajectory points
    l = strmatch('%%END_HEADER', data(:, 1));
    if isempty(l)
        err = 1;
    else
       for i = (l + 1):length(data)
           % extract time, X and Y coordinates
           if ~isempty(data{i, 1})
               t = sscanf(data{i, 2}, '%f');
               x = sscanf(data{i, 3}, '%f');
               y = sscanf(data{i, 4}, '%f');
               stat = sscanf(data{i, 6}, '%f'); % point status
               % discard missing smaples
               if ~isempty(t) && ~isempty(x) && ~isempty(y) && ~isempty(stat) && stat ~= config_place_avoidance.POINT_STATE_BAD
                   pts = [pts; t/1000. x y stat];
               end
           end
       end
    end
    
    fprintf('\nPoints: %d', size(pts, 1));
    pos = strfind(fn, 'rat');
    temp = sscanf(fn(pos(end):end), 'rat%dd%d');
    id = temp(1);
    trial = temp(2);
    
    if err
        exit('invalid file format');
    end
end