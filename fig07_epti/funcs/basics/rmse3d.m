function res = rmse3d(I1,varargin)
% RMSE returns the rmse error of Images;
%
%     res=rmse3d(I1) returns the L1-norm of I1
%     res=rmse3d(I1,I2) returns the RMSE between I1 and I2
%     res=rmse3d(I1,I2,ImageMask) returns the RMSE between I1 and I2 inside
%           the region of interest
%
% %%%%%%-------------------------------------%%%%%%
%Written by Fuyixue Wang on Jan.13.2017
% %%%%%%-------------------------------------%%%%%%
%

[a,b,c] = size(I1);
if(nargin==1)
    %res=norm(abs(I1),'fro');
    squareI1 = abs(I1).^2; 
    res = sqrt(sum(squareI1(:)));
else
    if(nargin==2)
        I2=varargin{1};
        ImageMask=ones(a,b,c);
    elseif(nargin==3) 
        I2=varargin{1};
        ImageMask=varargin{2};
    end
    diff = abs(I1.*ImageMask)-abs(I2.*ImageMask);
    squarediff = abs(diff).^2;
    res1 = sqrt (sum(squarediff(:)));
    squareI1 = abs(I1).^2; 
    res2 = sqrt(sum(squareI1(:)));
    res = res1/res2;
end
end

