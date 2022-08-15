
function [img_final] = Chan_Comb(start_img,s,is_simu,Noi_cor)
% d: data; 
% s: sensisitivity map
% n_iter: CG iter
% ncoil : coils
[Np,Nf,ncoil] = size(start_img);
img_final = zeros(Np,Nf);
C = zeros(Np,Nf);

if ~exist('is_simu','var')
    is_simu = 0;
end
if ~exist('Noi_cor','var')
    Noi_cor = eye(ncoil);
end
% intensity correction
% for j = 1:ncoil
%     C = C + conj(s(:,:,j)).*s(:,:,j);
%     img_final = img_final + start_img(:,:,j).* conj(s(:,:,j));
% end
% C = 1./sqrt(C);

for j = 1:ncoil
    sw = conj(s(:,:,j)).*sum(Noi_cor(:,j),1);
    C = C + sw.*s(:,:,j);
    img_final = img_final + start_img(:,:,j).* sw;
end
% C = 1./sqrt(C);
C = 1./(C);

if is_simu
    C = 1.;
end

img_final = img_final.*C;

% for i = 1:ncoil
%    img_final = kfilt(img_final);
% end






