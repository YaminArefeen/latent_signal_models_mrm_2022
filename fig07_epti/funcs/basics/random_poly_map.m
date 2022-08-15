function [ phase_map ] =random_poly_map( order,nx,ny,range )
%generate random phase map

[yc,xc] = meshgrid(linspace(-1/2,1/2,ny), linspace(-1/2,1/2,nx));
yc = yc(:);
xc = xc(:);
A = [];
for yp = 0:order
  for xp = 0:(order-yp)
    A = [(xc.^xp).*(yc.^yp) A];
  end
end
Np = size(A,2); 
c=rand(Np,1)*range;
phase_map=A*c;
phase_map=reshape(phase_map,[nx ny]);
end

