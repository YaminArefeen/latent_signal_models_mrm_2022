function [ f ] = fft1D(x,d)
%FFT1D Summary of this function goes here
%   Detailed explanation goes here
    if nargin<2
        d=1;
    end
    f=ifftshift(fft(ifftshift(x,d),[],d),d);

end

