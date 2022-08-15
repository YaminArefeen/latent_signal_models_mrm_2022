function [ maps ] = Espirit_smap( calib,imsize,eigThresh_1 )
% ESPIRiT Maps 
if nargin<3
    eigThresh_1=0.001
end
[~,~,Nc] = size(calib);
ksize = [6,6]; % kernel size
eigThresh_2 = 0;

[k,S] = dat2Kernel(calib,ksize);
idx = max(find(S >= S(1)*eigThresh_1));
% crop kernels and compute eigen-value decomposition in image space to get maps
[M,W] = kernelEig(k(:,:,:,1:idx),imsize);
% crop sensitivity maps 
% maps = M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,Nc]);
maps = M(:,:,:,end);
end

