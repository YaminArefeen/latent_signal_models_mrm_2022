function [ Imerr ] = err( I1,I2 )
%ERR Summary of this function goes here
%   Detailed explanation goes here
    Imerr=abs(abs(I1)-abs(I2));
end

