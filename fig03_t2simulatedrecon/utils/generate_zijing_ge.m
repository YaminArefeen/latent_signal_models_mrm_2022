function dictionary = generate_zijing_ge()

%load data and add appropriate paths
directory_data = 'utils/zijing_subspace_data/';
load([directory_data,'Prior_Estimates.mat'])
load([directory_data,'Acq_params.mat'])

T2vals=[5:1:100,102:3:200,210:10:300];
B0vals=[-50:1:50]; % unit Hz
K = 8; % subspace size
N = 256; % maximum number of unique T2s values for training

% pulse parameters
param.TEs_GRE = TEs(:);   % echo time for readout unit: s
dt =TEs(2)-TEs(1);
T2vals = T2vals/1000;

[U, dictionary] = gen_GE_basis_T2B0(N, nt_GE, t0, dt, T2vals, B0vals);
end