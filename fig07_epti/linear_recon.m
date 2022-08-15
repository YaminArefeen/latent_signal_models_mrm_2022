% perform locally low-rank linear reconstruction in matlab implementation to make sure BART isn't messed up
addpath 'utils' 'funcs'

%% setting parameters
%-setting parameters
gpuflag  = 1;
Ks       = [2,3];             %subspace rank of the linear reconstructions
iters    = 80;  

lambdas = [.02];

%% loading
%-loading dataset
fprintf('loading... ')
load('data/for_t2shfl.mat')
kspace = readcfl('data/kspace');

mask     = for_t2shfl.mask;
coils    = for_t2shfl.coils;

load('data/dictionary.mat')
[U_all,~,~] = svd(dictionary,'econ');

phase    = for_t2shfl.phase;

truth  = sum(conj(coils).*ifft2c(kspace),3) ./ (sum(conj(coils).*coils,3)+eps);
[M,N,C,E] = size(kspace);
fprintf('done\n')

%% putting stuff on gpu and generating under-sampled k-space
if(gpuflag)
    mask     = gpuArray(mask);
    coils    = gpuArray(coils);
    phase_T  = reshape(gpuArray(phase),M,N,1,E);
    U_all    = gpuArray(U_all);
    kspace   = gpuArray(kspace);
end

kdata       = ifftc(mask .* kspace,1);

[M,N,C,E] = size(kspace);


%% setting up non basis dependent linear operators
S_for = @(a)  coils.*a;
S_adj = @(as) sum(conj(coils).*as,3);

F_for = @(x) fftc_for(x,2);
F_adj = @(y) fftc_adj(y,2);

Ph_for = @(x) phase_T.*x;
Ph_adj = @(x) conj(phase_T) .* x;

% Sampling mask
P_for = @(y) bsxfun(@times, y, mask);
P_adj = P_for;

%% looping through each reconstruction
recons = zeros(M,N,E,length(Ks),length(lambdas));

for kk = 1:length(Ks)
    U = U_all(:,1:Ks(kk));
    
    T_for = @(a) reshape((U*reshape(a,M*N,Ks(kk)).').',M,N,1,E);
    T_adj = @(x) reshape((U'*reshape(x,M*N,E).').',M,N,1,Ks(kk));

    A_for = @(a) P_for(F_for(S_for(Ph_for(T_for(a)))));
    A_adj = @(y) T_adj(Ph_adj(S_adj(F_adj(P_adj(y)))));
    AHA   = @(x) A_adj(A_for(x));

    
    for ll = 1:length(lambdas)
        ksp_adj = A_adj(kdata);
        
        iter_ops.max_iter = iters;
        iter_ops.rho = .01;
        iter_ops.objfun = @(a, sv, lam) 0.5*norm_mat(kdata - A_for(a))^2 + lam*sum(sv(:));

        llr_ops.lambda = lambdas(ll);
        llr_ops.block_dim = [8, 8];

        lsqr_ops.max_iter = 10;
        lsqr_ops.tol = 1e-4;

        alpha_ref = RefValue;
        alpha_ref.data = zeros(M, N,1,Ks(kk));

        history = iter_admm(alpha_ref, iter_ops, llr_ops, lsqr_ops, AHA, ksp_adj, @admm_callback);
        disp(' ');
        
        recons(:,:,:,kk,ll) = reshape((U*reshape(alpha_ref.data,M*N,Ks(kk)).').',M,N,E);
    end
end

%% saving reconstructions
llr.recons  = recons;
llr.lambdas = lambdas;
llr.iters   = iters;
llr.Ks      = Ks;

save('data/linear_llr_ablation.mat','llr')