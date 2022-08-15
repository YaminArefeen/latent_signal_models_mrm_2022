function [K]=Img2K(Img)
%This function is used to change data from image domain into k-space
K=fftshift2(fft2(ifftshift2(Img)))/sqrt(size(Img,1)*size(Img,2));
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