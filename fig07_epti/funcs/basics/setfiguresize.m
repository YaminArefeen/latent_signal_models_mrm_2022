function [  ] = setfiguresize( x,y,s1,s2,lx,ly,type)
%SETFIGURESIZE Summary of this function goes here
%   Detailed explanation goes here
    switch lower(type)
        case 'table'
            w1=x*s1+(0.01*x+0.05)*s1/lx;
            w2=y*s2+(0.01*y+0.05)*s2/ly;
            scr_size=get(0,'screensize');
            r=min((scr_size(3)-200)/w2,(scr_size(4)-200)/w1);
            w1=w1*r;w2=w2*r;
            set(gcf,'position',[(scr_size(3)-w2)/2,(scr_size(4)-w1)/2,w2,w1]);
        case 'individual'
            w1=x*s1+(0.05*x+0.01)*s1/lx;
            w2=y*s2+(0.01*y+0.01)*s2/ly;
            scr_size=get(0,'screensize');
            r=min((scr_size(3)-200)/w2,(scr_size(4)-200)/w1);
            w1=w1*r;w2=w2*r;
            set(gcf,'position',[(scr_size(3)-w2)/2,(scr_size(4)-w1)/2,w2,w1]);
        case 'tilted'
            w1=x*s1+(0.01*x+0.01)*s1/lx;
            w2=y*s2+(0.01*y+0.01)*s2/ly;
            scr_size=get(0,'screensize');
            r=min((scr_size(3)-200)/w2,(scr_size(4)-200)/w1);
            w1=w1*r;w2=w2*r;
            set(gcf,'position',[(scr_size(3)-w2)/2,(scr_size(4)-w1)/2,w2,w1]);
        case 'listlr'
            w1=x*s1+(0.01*x+0.01)*s1/lx;
            w2=y*s2+(0.01*y+0.05)*s2/ly;
            scr_size=get(0,'screensize');
            r=min((scr_size(3)-200)/w2,(scr_size(4)-200)/w1);
            w1=w1*r;w2=w2*r;
            set(gcf,'position',[(scr_size(3)-w2)/2,(scr_size(4)-w1)/2,w2,w1]);
        case 'listud'
            w1=x*s1+(0.01*x+0.05)*s1/lx;
            w2=y*s2+(0.01*y+0.01)*s2/ly;
            scr_size=get(0,'screensize');
            r=min((scr_size(3)-200)/w2,(scr_size(4)-200)/w1);
            w1=w1*r;w2=w2*r;
            set(gcf,'position',[(scr_size(3)-w2)/2,(scr_size(4)-w1)/2,w2,w1]);
    end
end

