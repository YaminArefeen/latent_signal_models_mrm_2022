function res = rmse(I1,varargin)
% RMSE returns the rmse error of Images;
%
%     res=rmse(I1) returns the L1-norm of I1
%     res=rmse(I1,I2) returns the RMSE between I1 and I2
%     res=rmse(I1,I2,ImageMask) returns the RMSE between I1 and I2 inside
%           the region of interest
%
% %%%%%%-------------------------------------%%%%%%
%Written by Dan Zhu 2013/4/24
% %%%%%%-------------------------------------%%%%%%
%

[a,b] = size(I1);
if(nargin==1)
    res=norm(abs(I1),'fro');
else
    if(nargin==2)
        I2=varargin{1};
        ImageMask=ones(a,b);
    elseif(nargin==3) 
        I2=varargin{1};
        ImageMask=varargin{2};
    end
    res = norm(abs(I1.*ImageMask)-abs(I2.*ImageMask),'fro')...
        /norm(abs(I1.*ImageMask),'fro');
    %res = sqrt(sum(sum((abs(I1.*ImageMask)-abs(I2.*ImageMask)).^2))...
    %/(a*b))/(max(abs(I1(:)))-min(abs(I1(:))));
end
end