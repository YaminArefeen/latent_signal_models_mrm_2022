function [dictionary,t2_range,t1_range] = generate_tse_dictionary(angles,spacing,t2_range,t1_range,b1_range)
% generate a dictionary of tse signal evolution
% Inputs:
%   angles [radians],         etl x 1,        Set of flip angles [
%   spacing [seconds],        scalar,         Echo spacing
%   t2_range [seconds],       N x 1,          Range of T2 values to simulate
%   t1_range [seconds],       M x 1,          Range of T1 values to simulate
%   b1_range [seconds],       B x 1,          Range of B1 values to simulate

% Output:
%   dictionary [a.u],         etl x (M*N*B)   Dictionary of tse signal evolutions

if(nargin < 1)
    angles = 160 * ones(80 , 1) / 180 * pi; % [rad], train of flip angles
end

etl = length(angles);

if(nargin < 2)
    spacing = 5.56e-3;
end

if(nargin < 3)
    t2_range = [1:.1:400] / 1000;
end

if(nargin < 4)
%     t1_range = [1000:100:2000] / 1000;
    t1_range = [1000]/1000;
end

if(nargin < 5)
    b1_range = 1;
end

M = length(t2_range);
N = length(t1_range);
B = length(b1_range);

dictionary = zeros(etl,M*N*B);

ctr = 1;
for mm = 1:M
    for nn = 1:N
        for bb = 1:B
            dictionary(:,ctr) = FSE_signal(angles,spacing,t1_range(nn),t2_range(mm),b1_range(bb));
            ctr = ctr + 1;
        end
    end
end

end