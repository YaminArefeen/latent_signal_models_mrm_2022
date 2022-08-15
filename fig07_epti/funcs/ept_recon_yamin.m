function [im_recon,res_a,RELRES]=...
    epti_recon_yamin(kdata,mask,coils,phase,basis,a0,nIter,lambda)
    
    [M,N,C,E] = size(kdata);
    K         = size(basis,2);
    
    T_for = @(a) reshape((basis*reshape(a,M*N,K).').',M,N,1,E);
    T_adj = @(x) vec(reshape((basis'*reshape(x,M*N,E).').',M,N,K));
    
    P_for = @(x) bsxfun(@times, x, phase);
    P_adj = @(y) bsxfun(@times, y, conj(phase));
    
    S_for = @(a) coils.*a;
    S_adj = @(as) sum(conj(coils).*as,3);
    
    F_for = @(x) fft2c_for(x);
    F_adj = @(x) fft2c_adj(x);
    
    M_for = @(x) vec(mask .* x);
    M_adj = @(x) mask .* reshape(x,M,N,C,E);
    
    
    total_size=E*M*N*C;
    A_for = @(a) A_GESE_forward_Tik(a,lambda,T_for,P_for,S_for,F_for,M_for);
    A_adj = @(y) A_GESE_adjoint_Tik(y,total_size,lambda,T_adj,P_adj,S_adj,F_adj,M_adj); 

    a0 = a0(:);
    y0 = [kdata(:); 0*a0(:)];
    clear kdata;
    [res,FLAG,RELRES,ITER,RESVEC] = lsqr(@aprod,y0,1e-6,nIter, [],[],a0(:),A_for,A_adj);
    res_a=reshape(res,M,N,K);
    im_recon= squeeze(T_for(res));
end


function [res,tflag] = aprod(a,A_for,A_adj,tflag)	
	if strcmp(tflag,'transp')
        res = A_adj(a);
    else
        res = A_for(a);
    end
end