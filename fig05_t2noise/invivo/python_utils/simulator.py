from __future__ import division

import numpy as np
from warnings import warn
import torch

def get_precomputed_matrices(batch_size, alphas, T):
    """
    Returns the rotation matrix for the entire batch
    for the given flip angle train.
    """
    cosa2 = torch.cos(alphas / 2.0) ** 2
    sina2 = torch.sin(alphas / 2.0) ** 2
    cosa = torch.cos(alphas)
    sina = torch.sin(alphas)

    RR = torch.zeros(batch_size, 3, 3, T, device=alphas.device)

    RR[:, 0, 0, :] = cosa2
    RR[:, 0, 1, :] = sina2
    RR[:, 0, 2, :] = sina

    RR[:, 1, 0, :] = sina2
    RR[:, 1, 1, :] = cosa2
    RR[:, 1, 2, :] = -sina

    RR[:, 2, 0, :] = -0.5 * sina
    RR[:, 2, 1, :] = 0.5 * sina
    RR[:, 2, 2, :] = cosa
    return RR


def rf(matrices, FpFmZ):
    """Propagate EPG states through an RF rotation of
    alpha (radians), which are present for the entire batch
    in matrices. Assumes CPMG condition, i.e.
    magnetization lies on the real x axis.
    """
    return torch.matmul(matrices, FpFmZ)


def rf_ex(FpFmZ, alpha):
    "Same as rf2_ex, but only returns FpFmZ" ""
    return rf2_ex(FpFmZ, alpha)[0]


def rf2_ex(FpFmZ, alpha):
    """Propagate EPG states through an RF excitation of
    alpha (radians) along the y direction, i.e. phase of pi/2.
    in Pytorch
    INPUT:
        FpFmZ = N x 3 x (3T - 1) tensor of F+, F- and Z states
                for all elements in the batch.
        alpha = RF pulse flip angle in radians

    OUTPUT:
        FpFmZ = Updated FpFmZ state.
        RR = RF rotation matrix (3x3).

    """

    try:
        alpha = alpha[0]
    except:
        pass

    if torch.abs(alpha) > 2 * np.pi:
        warn("rf2_ex: Flip angle should be in radians! alpha=%f" % alpha)

    cosa2 = torch.cos(alpha / 2.0) ** 2
    sina2 = torch.sin(alpha / 2.0) ** 2

    cosa = torch.cos(alpha)
    sina = torch.sin(alpha)
    RR = torch.tensor(
        [
            [cosa2, -sina2, sina],
            [-sina2, cosa2, sina],
            [-0.5 * sina, -0.5 * sina, cosa],
        ],
        device=alpha.device,
    )
    FpFmZ = torch.matmul(RR, FpFmZ)

    return FpFmZ, RR


def relax_mat(T, T1, T2):
    """
    Creates and returns the decay matrix
    """
    E2 = torch.exp(-T / T2)
    E1 = torch.exp(-T / T1)

    # Decay of states due to relaxation alone.
    mat = torch.stack([E2, E2, E1], dim=1)
    EE = torch.diag_embed(mat)
    return EE


def relax(FpFmZ, EE, RR):
    """Propagate EPG states through a period of relaxation over
    an interval T.
    torch
    INPUT:
        FpFmZ = N x 3 x (3T - 1) tensor of F+, F- and Z states
                for all elements in the batch.
        EE = decay matrix, 3x3 = diag([E2 E2 E1]);
        RR = RF rotation matrix (3x3).

    OUTPUT:
        FpFmZ = updated F+, F- and Z states.

    """
    FpFmZ = torch.matmul(EE, FpFmZ)  # Apply Relaxation
    FpFmZ[:, 2, 0] = FpFmZ[:, 2, 0] + RR  # Recovery

    return FpFmZ


def grad(FpFmZ):
    """Propagate EPG states through a "unit" gradient. Assumes CPMG condition,
    i.e. all states are real-valued.

    INPUT:
        FpFmZ = N x 3 x (3T - 1) tensor of F+, F- and Z states
                for all elements in the batch.

    OUTPUT:
        Updated FpFmZ state.

    """
    x = FpFmZ.clone()  # required to avoid in-place memory op
    FpFmZ[:, 0, 1:] = x[:, 0, :-1]  # shift Fp states
    FpFmZ[:, 1, :-1] = x[:, 1, 1:]  # shift Fm states
    FpFmZ[:, 1, -1] = 0  # Zero highest Fm state
    FpFmZ[:, 0, 0] = FpFmZ[:, 1, 0]

    return FpFmZ


def FSE_TE(FpFmZ, i, EE, RR, matrices):
    """Propagate EPG states through a full TE, i.e.
    relax -> grad -> rf -> grad -> relax.
    Assumes CPMG condition, i.e. all states are real-valued.

    INPUT:
        FpFmZ = N x 3 x (3T - 1) tensor of F+, F- and Z states
                for all elements in the batch.
        i = Current flip angle
        EE = decay matrix, 3x3 = diag([E2 E2 E1]);
        RR = RF rotation matrix (3x3).
        matrices = Pre-computed rotation matrix for the entire batch
                   for the given flip angle train.

    OUTPUT:
        FpFmZ = updated F+, F- and Z states.

    """
    FpFmZ = relax(FpFmZ, EE, RR)
    FpFmZ = grad(FpFmZ)
    FpFmZ = rf(matrices[:, :, :, i], FpFmZ)
    FpFmZ = grad(FpFmZ)
    FpFmZ = relax(FpFmZ, EE, RR)

    return FpFmZ


# Full FSE EPG function across T time points
def FSE_signal_TR(angles_rad, TE, TRs, T1, T2, B1=1.0):
    """Same as FSE_signal2_TR, but only returns Mxy"""
    return FSE_signal2_TR(angles_rad, TE, TRs, T1, T2, B1)


def FSE_signal2_TR(angles_rad, TE, TRs, T1, T2, B1=1.0):
    """Same as FSE_signal2, but includes finite TR"""
    pi = torch.tensor(np.pi, device=T2.device)
    return FSE_signal2_TRs_ex(pi / 2, angles_rad, TE, TRs, T1, T2, 1.0)

def FSE_signal2_TRs_ex(angle_ex_rad, angles_rad, TE, TRs, T1, T2, B1=1.0):
    """Same as FSE_signal2_ex, but includes finite TR"""
    T = angles_rad.shape[1]
    Mxy, Mz = FSE_signal2_ex(angle_ex_rad, angles_rad, TE, T1, T2, B1)  # n x T x 1
    URs = torch.tensor(TRs - T * TE, device=angles_rad.device)  
    E1 = torch.exp(-URs[None, :] / T1[:, None])[:, None, :] # n x 3 -> n x 1 x 3
    sig = torch.flatten(Mxy * (1 - E1) / (1 - Mz[:, -1, :][:, None, :] * E1), start_dim=1)[:, :, None] # n x T x 3 -> n x 3T x 1
    return sig

def FSE_signal2_ex(angle_ex_rad, angles_rad, TE, T1, T2, B1=1.0):
    """Simulate Fast Spin-Echo CPMG sequence with specific flip angle train.
    Prior to the flip angle train, an excitation pulse of angle_ex_rad degrees
    is applied in the Y direction. The flip angle train is then applied in the X direction.

    INPUT:
        angles_rad = array of flip angles in radians equal to echo train length
        TE = echo time/spacing
        T1 = T1 value in seconds
        T2 = T2 value in seconds

    OUTPUT:
        Mxy = Transverse magnetization at each echo time
        Mz = Longitudinal magnetization at each echo time

    """
    batch_size = T2.shape[0]
    T = angles_rad.shape[1]
    Mxy = torch.zeros((batch_size, T, 1), requires_grad=False, device=T2.device)
    Mz = torch.zeros((batch_size, T, 1), requires_grad=False, device=T2.device)
    P = torch.zeros((batch_size, 3, 2 * T + 1), dtype=torch.float32, device=T2.device)
    P[:, 2, 0] = 1.0
    try:
        B1 = B1[0]
    except:
        pass

    # pre-scale by B1 homogeneity
    angle_ex_rad = B1 * angle_ex_rad
    angles_rad = B1 * angles_rad

    P = rf_ex(P, angle_ex_rad)  # initial tip
    EE = relax_mat(TE / 2.0, T1, T2)
    E1 = torch.exp(-TE / 2.0 / T1)
    RR = 1 - E1
    matrices = get_precomputed_matrices(batch_size, angles_rad, T)
    for i in range(T):
        P = FSE_TE(P, i, EE, RR, matrices)
        Mxy[:, i, 0] = P[:, 0, 0]
        Mz[:, i, 0] = P[:, 2, 0]
    return Mxy, Mz


def SE_sim(angle_ex_rad, angles_rad, TE, T1, T2, TR, B1=1.0):
    Mxy, Mz = FSE_signal2_ex(angle_ex_rad, angles_rad, TE, T1, T2, B1=1.0)
    par = 1 - torch.exp(-(TR - TE) / T1)
    return Mxy * par.float(), Mz
