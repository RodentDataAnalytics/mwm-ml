function [ distr ] = segment_classes_distribution(classes, k)
%CLASSIFY_TRAJECTORIES_DISTR distributes segments to classes
    % number of distinct trajectories
    ntraj = max(classes(:, 1));
    distr = zeros(ntraj, k);
    for i = 1:size(classes, 1)
        strat = classes(i, 5);
        itraj = classes(i, 1);
        if strat > 0
            distr(itraj, strat) = distr(itraj, strat) + 1;
        end
    end
end
