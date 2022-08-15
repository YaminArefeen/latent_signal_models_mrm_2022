function [ x ] = ifft1D(f,d)
%FFT1D Summary of this function goes here
%   Detailed explanation goes here
    if nargin<2
        d=1;
    end
    x=fftshift(ifft(fftshift(f,d),[],d),d);

end

