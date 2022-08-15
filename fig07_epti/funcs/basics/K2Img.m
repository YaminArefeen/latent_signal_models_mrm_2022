function [Img]= K2Img(K)
% Transform k-space data to image domaind
Img=ifftshift2(ifft2(fftshift2(K)))*sqrt(size(K,1)*size(K,2));
end


function [ y ] = fftshift2( x )
    numDims = ndims(x);
    idx = repmat({':'}, 1, numDims);
    for i=1:2
        m = size(x, i);
        p = ceil(m/2);
        idx{i} = [p+1:m 1:p];
    end
    y = x(idx{:});
end
function [ y ] = ifftshift2( x )
    numDims = ndims(x);
    idx = repmat({':'}, 1, numDims);
    for i=1:2
        m = size(x, i);
        p = floor(m/2);
        idx{i} = [p+1:m 1:p];
    end
    y = x(idx{:});
end