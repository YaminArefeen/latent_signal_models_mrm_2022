function [ sens_slice,B0_field,Phase0,im_GRE_combo ] = Preprocess_SubspaceRec_newBack( kdata,TEs_GRE,target_size,show_fig )
%   Preprocessing for EPTI sub-space recon
%   estimate sensitivity map, B0 feild and background phase
    if nargin<4
        show_fig=0;
    end
%%
    
    kdata = permute(kdata,[2,3,1,4]);
    [nx,ny,Necho,Ncoil] = size(kdata);    
    
    im_GRE=zeros([target_size,Necho,Ncoil]);
    
%     win=repmat(tukeywin(ny,0.6)',[nx,1]);
    win=1;
    for i=1:Necho
        for j=1:size(kdata,4)
            im_GRE(:,:,i,j)=ifft2c(zpad(kdata(:,:,i,j).*win,target_size));
        end
    end
   
%%  Sensitivity estimation
    % espirit:
    calib_size=min(32,ny);
    kdata_calib=crop(squeeze(kdata(:,:,1,:)),[calib_size,calib_size,Ncoil]);
    sens_slice(:,:,1,:) = Espirit_smap( kdata_calib,target_size,0.01);
    
    im_GRE_combo = sum( repmat( conj(sens_slice), [1,1,Necho,1]) .* im_GRE, 4) ./ (eps + repmat( sum(abs(sens_slice).^2, 4), [1,1,Necho]));
    %% B0_estimation    
    PHS = angle(im_GRE_combo);
%     im_mean=abs(mean(im_GRE_combo,3));
    im_mean=abs(im_GRE_combo(:,:,1));
    MSK_extended=(im_mean)>0.05*mean(im_mean(:));
    [ B0_field,fit_error ] = dB_fitting_JumpCorrect(PHS,TEs_GRE,logical(MSK_extended),1);
%     [ B0_field,fit_error ] = dB_fitting(PHS,TEs_GRE,logical(MSK_extended),1);
    %-----------------------------------------------------------------------
%     mask_largeError=fit_error>3*mean(fit_error(MSK_extended(:)));
%     mask_largeError(1:2,:)=0;
%     mask_largeError(end-1:end,:)=0;
%     mask_largeError(:,1:2)=0;
%     mask_largeError(:,end-1:end)=0;
%     index=find(mask_largeError);
%     [idy_all,idx_all]=meshgrid(1:target_size(2),1:target_size(1));
%     idy_all=idy_all(:);
%     idx_all=idx_all(:);
%     for i=1:length(index)
%         idy=idy_all(index(i));
%         idx=idx_all(index(i));
%         mean_value=B0_field(idx-1:idx+1,idy-1:idy+1);
%         mean_value=mean(mean_value(mean_value(:)~=0));
%         if mean_value==0
%             mean_value=B0_field(idx-2:idx+2,idy-2:idy+2);
%             mean_value=mean(mean_value(mean_value(:)~=0));
%         end
%         B0_field(idx,idy)=mean_value;
%     end
    %-----------------------------------------------------------------------
    if show_fig==1
        figure, imagesc(B0_field,[-50,50]);
    end
    %---------------------------------------------------------------------
    for t = 1:size(im_GRE_combo,3)
        Phase0(:,:,t)=(im_GRE_combo(:,:,t).*exp(-1i*2*pi*B0_field*TEs_GRE(t)));
    end
    Phase0=angle(mean(Phase0,3));
end