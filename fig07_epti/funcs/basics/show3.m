function [ h ] = show3( kspace )
%SHOW4 Summary of this function goes here
%   Detailed explanation goes here
    [nfe,npe,nf,nch]=size(kspace);
    Img=K2Img(kspace);
    for fr=1:nf
        Img1(:,:,fr)=SOS_phase(Img(:,:,fr,:));
    end
    row=ceil(sqrt(nfe));
    colum=ceil(nf/row);
end

