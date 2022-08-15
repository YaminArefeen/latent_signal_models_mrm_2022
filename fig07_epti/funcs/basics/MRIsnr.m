function snrMRI = MRIsnr(image,loc_signal,loc_noise)
% loc_signal = [nx1,nx2,ny1,ny2];
% loc_noise = [nx1,nx2,ny1,ny2];
% by Fuyixue Wang, Jan.13,2017
signal = abs(image(loc_signal(1):loc_signal(2),loc_signal(3):loc_signal(4)));
signal = mean(signal(:));
noise = abs(image(loc_noise(1):loc_noise(2),loc_noise(3):loc_noise(4)));
noise = std(noise(:));
snrMRI = signal / noise;
end

