function [ S ] = SMap( kData,ACSsize,phasesensitive)
%SMAP Calculate the Sensitivity Maps with traditional SOS method
%   S=SMap(kData,Size,phase)
%   
%   Output S: Sensitivity map
%   Input kData: k-Space data
%   Input Size: Calibration size, default value is the whole k-space
%   Input phase: if phase=1 for phase sensitive recon phase=0 for non phase
%       sensitive recon, default value is 1;
%
%  by Dan Zhu 2014
    [nfe,npe,nch]=size(kData);
    if nargin<2
        ACSsize=[nfe,npe];
    end
    
    if numel(ACSsize)>2;
        ACSsize=ACSsize(1:2);
    end
    
    if ACSsize(1)>nfe
        ACSsize(1)=nfe;
    end

    if ACSsize(2)>npe
        ACSsize(2)=npe;
    end
    
    if nargin<3
        phasesensitive=1;
    end
    
    ACS{1}=round((nfe-ACSsize(1))/2):round((nfe-ACSsize(1))/2+ACSsize(1)-1);
    ACS{2}=round((nfe-ACSsize(2))/2):round((nfe-ACSsize(2))/2+ACSsize(1)-1);
    ACS{3}=1:nch;
    
    kC=zeros(size(kData));
    kC(ACS{:})=kData(ACS{:});
    win=tukeywin2([nfe,npe],0.5,min(ACSsize));
    kC=kC.*repmat(win,[1,1,nch]);   % tukey window
    
    Img=K2Img(kC);
    if phasesensitive
        S=Img./repmat(SOS_phase(kC),[1,1,nch]);
    else
        S=Img./repmat(sos(Img),[1,1,nch]);
    end
    
end

function f=tukeywin2(N,r,D)
    [x,y]=meshgrid(1:N(1),1:N(2));
    k=(sqrt((x-N(1)/2).^2+(y-N(2)/2).^2)+(D/2))/D;
    f=zeros(N);
    idx2=(k>=r/2 & k<1-r/2);
    f(idx2)=1;
    idx3=(k>=1-r/2 & k<=1);
    f(idx3)=(1+cos(2*pi/r*(k(idx3)-1+r/2)))/2;
end

