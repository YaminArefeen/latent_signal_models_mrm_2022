function [Img]= K2Img3D(K)
% Transform k-space data to image domaind
Img=ifft1D(K2Img(K),3);
end