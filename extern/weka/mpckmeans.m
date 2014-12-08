function [ distr, centroids ] = mpckmeans( x, constr, k )
%MPCKMEANS MPCK clustering algorithm
%   x is the input data, constr a constrain matrix 
%   k is the desired number of clusters
    import weka.clusterers.MPCKMeans;
    import weka.clusterers.InstancePair;
    import weka.core.metrics.*;
    import java.io.*;
    import java.util.*;
    import weka.core.*;       
    
    d = size(x);
            
    % create attributes vector
    attr = FastVector();
    for i = 1:d(2)
        name = sprintf('feat%d', i);
        attr.addElement(Attribute(name)); 
    end
    %reader = FileReader('/tmp/iris.arff');
	data = Instances('data', attr, d(1));
    
    for i = 1:d(1)
        data.add( Instance(1.0, x(i, :)));
    end
    
    % constraints
    c = ArrayList();
    for i = 1:size(constr,1)
        if constr(i,1) < constr(i,2)
            c.add( InstancePair(constr(i,1) - 1, constr(i,2) - 1, InstancePair.MUST_LINK));
        else
            c.add( InstancePair(constr(i,2) - 1, constr(i,1) - 1, InstancePair.CANNOT_LINK));
        end
    end
                
    mpck = weka.clusterers.MPCKMeans();
    mpck.setTotalTrainWithLabels(data);    
    %mpck.setCannotLinkWeight(1000);
    % constraints = c.readConstraints('/tmp/iris.constraints');
    mpck.buildClusterer(c, data, data, k, data.numInstances())    
    % c.printClusterAssignments();
    distr = mpck.getClusterAssignments();
    distr = distr';
    centroids_inst = mpck.getClusterCentroids();
    centroids = zeros(k, d(2));
    for i = 1:k
        % don't forget - java indices are zero based!
        centroids(i, :) = centroids_inst.instance(i - 1).toDoubleArray();
    end
    centroids = centroids';
end