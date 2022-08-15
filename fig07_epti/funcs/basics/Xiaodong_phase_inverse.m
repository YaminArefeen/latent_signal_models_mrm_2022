% method 1
% navigator phase conjugation
function [ ksp_nav_new ] = Xiaodong_phase_inverse( ksp_nav,ksp_nav_b0 )
[Nfe_nav,Npe_nav,Nc,Nex,Nshot]=size(ksp_nav);
im_nav = ifft2c(ksp_nav);
im_nav0 = ifft2c(ksp_nav_b0);
im_nav0 = mean(mean(im_nav0,5),4); % average the navigator of all shots and all NSA/NEX
% s_nav0 = im_nav0./repmat(sos(im_nav0),[1 1 Nc]); % obtain the coil sensitivity maps
s_nav0 = im_nav0./repmat(SOS_phase(im_nav0,0),[1 1 Nc]); % obtain the coil sensitivity maps

im_nav_comb = zeros(Nfe_nav,Npe_nav);
ksp_nav_new = zeros(size(ksp_nav));
for nshot = 1:Nshot
    for nex = 1:Nex
    im_nav_comb = Chan_Comb(im_nav(:,:,:,nex,nshot),s_nav0); % channel combine
    ksp_nav_new(:,:,:,nex,nshot) = fft2c(s_nav0.*repmat(conj(im_nav_comb),[1 1 Nc]));% image conjugation
    end
end

% method 2
% ksp_nav_new = zeros(size(ksp_nav));
% for nshot = 1:Nshot
%     for nex = 1:Nex
%         ksp_nav_new(:,:,:,nex,nshot) = fft2c(conj(im_nav(:,:,:,nex,nshot)./im_nav0).*im_nav0);
%     end
% end