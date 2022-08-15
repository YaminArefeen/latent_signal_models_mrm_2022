% Simulate the t2-shuffling dictionary, both for t2-shuffling reconstruction and for autoencoder / decoder training
addpath 'utils'

%% Setting parameters
etl         = 80;                       %[a.u]
ref_angle   = 160;                      %[degrees]
spacing     = 5.56e-3;                  %[s]
t2_range    = [50:1:400] / 1000;        %[s]
t1_range    = [1000:1000:2000] / 1000;   %[s]
b1_range    = 1;

angles = ref_angle * ones(etl,1) / 180 * pi; %[rad], train of flip angles

%% simulating dictionary
fprintf('simulating... ')
dictionary = generate_tse_dictionary(angles,spacing,t2_range,t1_range,b1_range);
fprintf('done\n')

%% setting dictionary params
dictionary_params.etl           = etl;
dictionary_params.ref_angle     = ref_angle;
dictionary_params.spacing       = spacing;
dictionary_params.t2_range      = t2_range;
dictionary_params.t1_range      = t1_range;
dictionary_params.b1_range      = b1_range;
dictionary_params.angles        = angles;

%% saving the dictionary
save('data/dictionary.mat', 'dictionary')
save('data/dict_params.mat','dictionary_params')