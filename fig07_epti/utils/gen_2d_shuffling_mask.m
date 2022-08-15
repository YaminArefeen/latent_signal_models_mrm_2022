function mask = gen_2d_shuffling_mask(M,N,shots,etl)    
mask = zeros(M,N,1,etl);

%generating 2D acquisition mask
for ss = 1:shots
    for ii = 1:etl % (assuming phase-encoding second spatial dimension)
        mask(:,randi(N),:,ii) = 1;
    end
end

end