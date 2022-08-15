% Prepare T2-shuffling reconstrcution based on parameters from dictionary simulation
% -multi-coil k-space data + associated time series of images
% -under-sampling mask at each echo
addpath 'utils'

%% parameters
noise_level = .001;     %std of gaussian noise added to k-space % 0 -> when doing monte-carlo
shots       = 4;

%% loading simulated dictionary parameters and numerical phantom
load('data/dict_params.mat')
load('data/sb256.mat')
load('data/T1map.mat'); T1 = x / 1000; clear x
load('data/M0map.mat'); M0 = x;        clear x
[M,N,C] = size(sb256.esp);
etl     = dictionary_params.etl;

%% generating undersamling mask
fprintf('generating undersampling mask... ')
mask = zeros(M,N,1,etl);

%generating 2D acquisition mask
for ss = 1:shots
    for ii = 1:etl % (assuming phase-encoding second spatial dimension)
        mask(:,randi(N),:,ii) = 1;
    end
end
fprintf('done\n')


%% Simulating signal evolution for each voxel in numerical phantom
timeseries_truth = zeros(M,N,etl);
T2_map           = double(sb256.T2);
T1_map           = T1;

fprintf('simulating signal... ')
for mm = 1 : M
    for nn = 1 : N
        if(T2_map(mm,nn) == 0)
            continue
        else
            timeseries_truth(mm,nn,:) = FSE_signal(dictionary_params.angles,dictionary_params.spacing,...
                T1_map(mm,nn),T2_map(mm,nn),1);
            
            timeseries_truth(mm,nn,:) = timeseries_truth(mm,nn,:) * M0(mm,nn);
        end
    end
end

fprintf('done\n')

%% acquired fully_sampled temporal k-space
coils               = sb256.esp; C = size(coils,3);
timeseries_truth    = reshape(timeseries_truth,M,N,1,etl);

kspace = mfft2(coils.*timeseries_truth) + noise_level * (randn(M,N,C,etl) + 1i * randn(M,N,C,etl));

%% saving for t2-shuffling reconstruction
for_t2shfl.mask         = mask;
for_t2shfl.kspace       = kspace;
for_t2shfl.coils        = coils;
for_t2shfl.timeseries   = timeseries_truth;
for_t2shfl.noise_level  = noise_level;
for_t2shfl.shots        = shots;

fprintf('saving... ')
save('data/for_t2shfl.mat','for_t2shfl')
fprintf('done\n') 