function mask = gen_3d_shuffling_mask(M,N,Rx,Ry,etl)
mask = zeros(M,N,1,etl);

%-generate a 3d shuffling sampling mask
mask_notemp = zeros(M,N);
mask_notemp(1:Rx:end,1:Ry:end) = 1;

total_samples           = sum(vec(mask_notemp));
samples_per_timepoint   = floor(total_samples / etl);

nonzero_indices         = find(vec(mask_notemp));
nonzero_indices_shuffle = nonzero_indices(randperm(length(nonzero_indices)));

for ee = 1:etl
    cur_mask = zeros(M*N,1);

    cur_mask(nonzero_indices_shuffle((ee-1)*samples_per_timepoint + 1:ee*samples_per_timepoint)) = 1;
    cur_mask = reshape(cur_mask,M,N);

    mask(:,:,:,ee) = cur_mask;
end

end