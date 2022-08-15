function bo = genBoMap(meanBo,stdBo,resLowBo,resHighBo)
%In this function, I want to generate a B0 map in the same spirit as described in: "high-resolution brain metabolite mapping on a clinical 3T MRI by accelereated H-FID-MRSI and low-rank constrained reconstruction" (Klauser, 2019).  In particular, generate a lowResolution Bo map using gaussian noisse from a specified mean and standard deviation.  I will then interpolate up to the desired high resolution so that the resulting B0 map is smooth and slowly varying, as is usally seen invivo
%Inputs:
%   meanBo,         - Mean of gaussian used to generate deltabo
%   stdBo,          - Standard deviation of gaussian
%   rewLowBo,       - Number of pixels in the low resolution delta bo map which will be interpolated to high resolution
%   resHighBo,      - Number of pixles in hte high resolution delta bo map
%Outputs:
    %bo, resHighBo x resHighBo, High resolution, slowly varying bo map in Hertz
if(nargin < 1 || isempty(meanBo))
    meanBo    = 0;
end

if(nargin < 2 || isempty(stdBo))
    stdBo = 10;
end

if(nargin < 3 || isempty(resLowBo))
    resLowBo = 8;
end

if(nargin < 4 || isempty(resHighBo))
    resHighBo = 256;
end


lowBo = normrnd(meanBo,stdBo,resLowBo);

interpolationNumbers = log(resHighBo/resLowBo)/log(2); %number of times i'll have to interpolate by a factor of two to get desired resolution

bo = lowBo;

for ii = 1:interpolationNumbers
    if(mod(ii,2) == 0)
        bo = padarray(interp2(bo,'spline'),[1,1],0,'post');
    else
        bo = padarray(interp2(bo,'spline'),[1,1],0,'pre');
    end
end

end %end of function
