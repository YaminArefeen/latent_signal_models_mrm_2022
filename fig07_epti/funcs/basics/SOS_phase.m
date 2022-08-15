function [Imref,mask]=SOS_phase(data,isk,depth)
    if nargin<=2
        depth=0;
    end
    if nargin<=1
        isk=0;
    end
    data=squeeze(data);
    if isk
        Image=ifft2c(data);
    else
        Image=data;
    end
    dim=ndims(data);
    SOSImage=sqrt(sum(abs(Image).^2,dim));
    Imref=SOSImage.*sum(Image,dim)./(abs(sum(Image,dim))+eps);
    if depth
        mask=getMask(SOSImage,depth);
        Imref=Imref.*mask;
    end
end