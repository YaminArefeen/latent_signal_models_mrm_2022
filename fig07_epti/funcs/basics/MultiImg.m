function [  ] = MultiImg(I,S,Imtitle,scale,varargin)
%MULTIIMAGES Summary of this function goes here
%   Detailed explanation goes here
    if nargin<1
        return
    end
    N=length(I);
    if N==0
        return
    end
    if nargin<2 || ( nargin>=2 & numel(S)==0 )
        S(1)=ceil(sqrt(N));
        S(2)=ceil(N/S(1));
    elseif numel(S)>2
        S=S(1:2);
    elseif numel(S)==1
        S(2)=ceil(N/S(1));
    end
    
    if N>prod(S)
        S(2)=ceil(N/S(1));
    end
    
    if nargin<3
        Imtitle={};
    end
    if nargin<4
        scale=[];
    end
    
    N2=length(Imtitle);
    
    for idx=1:N
        if numel(I{idx})==0
            continue
        end
        [l1,l2]=subplot2(S(1),S(2),idx,'Individual');
        showImg(I{idx},3,scale);
        if idx<=N2
            title(Imtitle{idx},'position',[size(I{idx},1),0]/2,varargin{:});
        end
    end
    
    setfiguresize(S(1),S(2),size(I{1},1),size(I{1},2),l1,l2,'Individual');
end

