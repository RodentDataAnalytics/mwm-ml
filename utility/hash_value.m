function hash = hash_value( val )
%HASH_VALUE Summary of this function goes here
%   Detailed explanation goes here
    if length(val) > 1
        hash = hash_value(val(1));
        for i = 2:length(val)
            hash = hash_combine(hash, hash_value(val(i)));
        end
    else    
        hash = uint32(mod(val*2654435761, 2^32));
    end
end