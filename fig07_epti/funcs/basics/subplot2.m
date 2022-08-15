function [ lx,ly] = subplot2(x,y,idx,type)
%SUBPLOT2 Summary of this function goes here
%   Detailed explanation goes here
    switch lower(type)
        case 'table'
            lx=(1-0.01*x-0.05)/x;
            ly=(1-0.01*y-0.05)/y;
            idx_x=ceil(idx/y);
            idx_y=idx-(idx_x-1)*y;
            xp=1-(idx_x*lx+idx_x*0.01+0.04);
            yp=(idx_y-1)*ly+idx_y*0.01+0.04;
            subplot('position',[yp,xp,ly,lx]);
        case 'listlr'
            lx=(1-0.01*x-0.01)/x;
            ly=(1-0.01*y-0.05)/y;
            idx_x=ceil(idx/y);
            idx_y=idx-(idx_x-1)*y;
            xp=1-(idx_x*lx+idx_x*0.01);
            yp=(idx_y-1)*ly+idx_y*0.01+0.04;
            subplot('position',[yp,xp,ly,lx]);
        case 'listud'
            lx=(1-0.01*x-0.05)/x;
            ly=(1-0.01*y-0.01)/y;
            idx_x=ceil(idx/y);
            idx_y=idx-(idx_x-1)*y;
            xp=1-(idx_x*lx+idx_x*0.01+0.04);
            yp=(idx_y-1)*ly+idx_y*0.01;
            subplot('position',[yp,xp,ly,lx]);
        case 'tilted'
            lx=(1-0.01*x-0.01)/x;
            ly=(1-0.01*y-0.01)/y;
            idx_x=ceil(idx/y);
            idx_y=idx-(idx_x-1)*y;
            xp=1-(idx_x*lx+idx_x*0.01);
            yp=(idx_y-1)*ly+idx_y*0.01;
            subplot('position',[yp,xp,ly,lx]);
        case 'individual'
            lx=(1-0.05*x-0.01)/x;
            ly=(1-0.01*y-0.01)/y;
            idx_x=ceil(idx/y);
            idx_y=idx-(idx_x-1)*y;
            xp=1-(idx_x*lx+idx_x*0.05);
            yp=(idx_y-1)*ly+idx_y*0.01;
            subplot('position',[yp,xp,ly,lx]);
        otherwise
    end
end

