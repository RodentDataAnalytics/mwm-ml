function result = iff(condition, trueResult, falseResult)
% Source: http://www.mathworks.com/matlabcentral/newsreader/view_thread/158054  
    error(nargchk(3,3,nargin));
    if condition
        result = trueResult;
    else
        result = falseResult;
    end
end