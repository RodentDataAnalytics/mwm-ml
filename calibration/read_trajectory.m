function [ rat, trial, pts ] = read_trajectory( fn )
%READ_TRAJECTORY Reads a trajectory from a file (native Ethovision format
%supported)
    % use a 3rd party function to read the file; matlab's csvread is    
    % totaly useless for anything other than perfectly formatted, value
    % only CSV files        
    addpath(fullfile(fileparts(mfilename('fullpath')),'../extern'));
    if ~exist(fn, 'file')
        error('Non-existent file');
    end
    data = robustcsvread(fn);
    err = 0;
    pts = [];
      
    %%
    %% parse the file
    %%
    l = strmatch('rat', data(:, 1));
    if isempty(l)
        l = strmatch('id', data(:, 1));
    end
    if isempty(l)
        err = 1;            
    end
    rat = sscanf(data{l, 2}, '%d');
    l = strmatch('trial', data(:, 1));
    if isempty(l)
        err = 1;
    end    
    trial = sscanf(data{l, 2}, '%d');
    
    % look for beggining of trajectory points
    l = strmatch('Sample no.', data(:, 1));
    if isempty(l)
        err = 1;
    else
       for i = (l + 1):length(data)
           % extract time, X and Y coordinates
           t = sscanf(data{i, 2}, '%f');
           x = sscanf(data{i, 3}, '%f');
           y = sscanf(data{i, 4}, '%f');
           % discard missing smaples
           if ~isempty(t) && ~isempty(x) && ~isempty(y)
               pts = [pts; t x y];
           end
       end
    end
        
    if err
        exit('invalid file format');
    end
end