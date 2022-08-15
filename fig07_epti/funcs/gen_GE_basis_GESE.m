function [U, X0] = gen_GE_basis_GESE(N1,N2, TEs_GRE, TEs_SE, TE_SE, T2svals,T2vals,deltaS0)
% Generate basis
%
% Inputs:
%  N1/N2 -- maximum number of T2/T2* signals to simulate
%  ETL -- echo train length
%  T0 -- initial echoes time
%  TE (s) -- echo spacing
%  T2vals (s) -- array of T2 values to simulate
%  deltaS0: scaling factor between GE and SE signals due to potential B1
%  inhomoengeity
% Outputs:
%  U -- temporal basis based on PCA
%  X -- [T, L] matrix of simulated signals

if length(T2svals) > N1
    idx = randperm(length(T2svals));
    T2svals = T2svals(idx(1:N1));
end
if length(T2vals) > N2
    idx = randperm(length(T2vals));
    T2vals = T2vals(idx(1:N1));
end
% TEs_GRE=(dt:dt:ETL*dt)+T0;
np_GRE=size(TEs_GRE,1);
np_SE=size(TEs_SE,1);
np_SE1=find(TEs_SE>TE_SE,1)-1;
nt=np_GRE+np_SE;

LT1 = length(T2svals);
LT2 = length(T2vals);
LT3 = length(deltaS0);
                        
X0 = zeros(nt, LT1*LT2*LT3);
num=0;
for ii=1:LT3
    S0_change=deltaS0(ii);
    for jj=1:LT2
        R2 = 1/T2vals(jj);
        for kk=1:LT1
            R2s = 1/T2svals(kk);
            if (R2s>=R2) && (R2s/R2<10)
                num=num+1;
                R2_p=R2s-R2;
                X0(1:np_GRE,num)=exp(-TEs_GRE(:)*R2s);
                X0(np_GRE+1:np_GRE+np_SE1,num)=S0_change.*exp(-TE_SE*R2_p).*exp(-TEs_SE(1:np_SE1)*(R2-R2_p));
                X0(np_GRE+np_SE1+1:end,num)=S0_change.*exp(TE_SE*R2_p).*exp(-TEs_SE(np_SE1+1:end)*R2s);
            end
        end
    end
end
X0=X0(:,1:num);

[U, ~, ~] = svd(X0, 'econ');

end