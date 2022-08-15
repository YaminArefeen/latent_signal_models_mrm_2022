function [K]=Img2K3D(Img)
%This function is used to change data from image domain into k-space
K=fft1D(Img2K(Img),3);
end