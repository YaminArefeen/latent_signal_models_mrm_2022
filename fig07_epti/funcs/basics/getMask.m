function [ mask ] = getMask( image, depth )
%GETMASK Summary of this function goes here
%   Detailed explanation goes here
    if nargin==1 depth=15; end
    [n,x]=hist(mat2gray(abs(image)),100);
    mask=im2bw(mat2gray(abs(image)),x(depth));
    mask=imfill(medfilt2(double(mask)),'holes');
end