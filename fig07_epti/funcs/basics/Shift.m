function [ kDataout ] = Shift( kDatain , dimension )
%SHIFT do the process on k-space data to shift the image to the center.
%
%   [ kDataout ] = Shift( kDatain , dimension )
%     -kDatain: input the k-space data of the unshifted image
%     -dimension: the dimension that you want to shift this image
%
%     -kDataout: give the final shifted image
%
% %%%%%%---------------------------------------------%%%%%%
%      Written by Dan Zhu, Ziyang Lan, Jingting Xu 2013/4/23
% %%%%%%---------------------------------------------%%%%%%
%

    [npe,nfe]=size(kDatain);
    kDataout=kDatain;
    switch dimension
        case 1
            kDataout(1:2:npe,:)=-kDatain(1:2:npe,:);
        case 2
            kDataout(:,1:2:nfe)=-kDatain(:,1:2:nfe);
    end
end

