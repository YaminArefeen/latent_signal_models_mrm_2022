import numpy as np
import torch

def reshape_fortran(x, shape):
    if len(x.shape) > 0:
        x = x.permute(*reversed(range(len(x.shape))))
    return x.reshape(*reversed(shape)).permute(*reversed(range(len(shape))))


def im2col_distinct(A,bd):
    nrows = bd[0]
    ncols = bd[1]

    nele = nrows*ncols
    pts  = A.shape[0]*A.shape[1]

    t1 = reshape_fortran(A,(nrows,A.shape[0]//nrows,A.shape[1]))
    t2 = t1.permute((0,2,1))
    t3 = reshape_fortran(t2,(t1.shape[0]*t1.shape[2],t1.shape[1]))
    t4 = reshape_fortran(t3,(nele,t3.shape[0]//nele,t3.shape[1])).permute((0,2,1))
    return reshape_fortran(t4,(nele,t4.shape[1]*t4.shape[2]))

def col2im_distinct(A,bd,dims):
    nrows = dims[0] // bd[0]
    ncols = dims[1] // bd[1]
    nele  = nrows * ncols

    t1 = reshape_fortran(A,(A.shape[0],nrows,ncols))   
    t2 = reshape_fortran(t1.permute((0,2,1)),(t1.shape[0]*t1.shape[1],t1.shape[2]))
    t3 = reshape_fortran(t2,(bd[0],dims[0],nrows)).permute((0,2,1))
    return reshape_fortran(t3,(dims[0],dims[1]))

def soft_thresh(y,t):
    res = (torch.abs(y) - t)
    res = (res + torch.abs(res))/2
    return torch.exp(1j * torch.angle(y)) * res

def matmul_complex(t1,t2):
    return torch.view_as_complex(torch.stack((t1.real @ t2.real - t1.imag @ t2.imag, t1.real @ t2.imag + t1.imag @ t2.real),dim=2))


def llr_thresh(alpha,lam,bd,rand):

    dims = alpha.shape
    Wy = bd[0]
    Wz = bd[1]

    [ny,nz,K] = alpha.shape
    L = ny * nz // Wy // Wz

    if rand:
        shift   = (np.random.randint(Wy),np.random.randint(Wz))
        alpha = torch.roll(alpha,shifts = shift,dims = (0,1))

    alpha_LLR = torch.zeros((Wy*Wz,L,K),dtype=torch.cfloat)

    for ii in range(K):
        alpha_LLR[:,:,ii] = im2col_distinct(alpha[:,:,ii],[Wy,Wz])
    alpha_LLR = alpha_LLR.permute((0,2,1))

    s_LLR        = torch.zeros((K,L),dtype=torch.cfloat)
    s_vals       = torch.zeros((K,L),dtype=torch.cfloat)

    for ii in range(L):
        [u,s,v] = torch.svd(alpha_LLR[:,:,ii],some=True)
        s_LLR[:,ii] = s
        s2 = soft_thresh(s_LLR[:,ii],lam)
        s_vals[:,ii] = s2

        alpha_LLR[:,:,ii] = \
            matmul_complex(matmul_complex(u,torch.diag(torch.real(s2)) + 1j * torch.diag(torch.imag(s2))),\
                          torch.conj(v.permute((1,0))))

    alpha_thresh = torch.zeros(alpha.shape,dtype=torch.cfloat)
    for ii in range(K):
        alpha_thresh[:,:,ii] = col2im_distinct(alpha_LLR[:,ii,:],bd,dims)

    if rand:
        alpha_thresh = torch.roll(alpha_thresh,shifts = (-shift[0],-shift[1]),dims = (0,1))
        
    return alpha_thresh