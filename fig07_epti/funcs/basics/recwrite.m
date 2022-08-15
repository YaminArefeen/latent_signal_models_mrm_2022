function [] = recwrite(img,patientname,method,bvalue,resize,resize_type)
% recwrite(abs(img_final).*repmat(circmask(244,244),[1 1 16 10]),'XiaodongMa','SENSECG_maskcirc_bicubic',800,2,'bicubic');
% if ~exist('patientname','var') || patientname == []
%     patientname='';
% end
if ~exist('resize_type','var')
    resize_type='bilinear';
end
if ~exist('resize','var')
    resize_type=2;
end

[Nx,Ny,Ndir,Nloc] = size(img);
for i=1:Nloc
    for j=1:Ndir
%     if j==1
    img_resize(:,:,i,j)=(imresize(abs(img(:,:,j,i)),resize,resize_type));
%     else
%     dwi_img_all_sos_resize(:,:,i,j-15)=(imresize(abs(img(:,:,j,i)),2,resize_type));
%     end
    end
end
m = max(img_resize(:));
scale = 60000/m;
% scale = 65536/m;
dwi_scale = img_resize*scale;
dwi_scale_uint16 = uint16(dwi_scale);
if strcmp(patientname,'') == 1
    filename = [method,'_b',num2str(bvalue),'_',num2str(Ndir),'dir_',num2str(Nx),'_',num2str(Ny),...
        '_',num2str(Nloc),'slice_',resize_type,num2str(resize)];
else
    filename = [patientname,'_',method,'_b',num2str(bvalue),'_',num2str(Ndir),'dir_',num2str(Nx),'_',num2str(Ny),...
        '_',num2str(Nloc),'slice_',resize_type,num2str(resize)];
end
writemr([filename,'.rec'],dwi_scale_uint16,'volume');