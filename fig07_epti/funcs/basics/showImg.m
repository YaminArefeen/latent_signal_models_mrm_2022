function [h]=showImg(data,type,scale)
%SHOWIMG Summary of this function goes here
%   Detailed explanation goes here
    if nargin<1
        return;
    elseif nargin<2
        type=1;
    end
    data=squeeze(data);
    if type==1;
        Im=SOS_phase(data);
    elseif type==2
        Im=sqrt(sum(abs(data).^2,3));
    else
        Im=data;
    end
    if nargin<3;
        scale=[0,norm(Im(:))/sqrt(numel(Im))*2];
    end
    htemp=imshow(abs(Im),scale,'border','tight');axis off;colormap gray;
    if nargout==1
        h=htemp;
    end
    [s1,s2]=size(Im);
    m=get(gcf,'Position');
    rx=m(3)/s2;ry=m(4)/s1;
    if rx>ry
        m(3)=ry*s2;
    elseif ry>rx
        m(4)=rx*s1;
    end
    set (gcf,'Position',m);
end

