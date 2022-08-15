function showImg2(data,varargin)
%SHOWIMG2 shows figures conviniently
% h=showImg2(data,parameters);
% parameters:
%    scale: a vector with a size of 2;
%    type:  0, keep data as it is
%           1, transfer k-space to image, default
%           2, transfer image to k-space
%    Combine: Combine multi-coil images,
%               coil dimension must be the last one
%             'SOS': sum-of square with phase
%             'mean': average
%    figtitle: a string (Not used currently......)

    % default value
    scale='default';
    type=1;
    combine='sos';
    figtitle='';
    
    % parameters
    for idx=1:nargin-1
        if ischar(varargin{idx})
            switch lower(varargin{idx})
                case 'off'
                    combine='off';
                case 'sos'
                    combine='sos';
                case 'mean'
                    combine='mean';
                otherwise
                    figtitle=varargin{idx};
            end
        elseif length(varargin{idx})==1
            type=varargin{idx};
            type=round(type);
            if type>2
                type=2;
            elseif type<0
                type=0;
            end
        elseif length(varargin{idx})==2
            scale=varargin{idx};
        end
    end
        
    % get the dimension of data
    data=squeeze(data);
    dimsImg=ndims(data)-1+strcmp(combine,'off');
    % show images
    if dimsImg==2
        Im=trans(data,type,combine);
        if strcmp(scale,'default')
            scale=[0,norm(Im(:))/sqrt(numel(Im))*2];
        end
        imshow(abs(Im),scale);
    elseif dimsImg==3
        showImg3(data,type,combine,scale);
    end
end

function data_out=trans(data_in,type,combine)
    switch type
        case 0
            data_out=data_in;
        case 1
            data_out=K2Img(data_in);
        case 2
            data_out=Img2K(data_in);
    end
    switch combine
        case 'sos'
            data_out=SOS_phase(data_out,0);
        case 'mean'
            dimsData=ndims(data_out);
            data_out=mean(data_out,dimsData);
    end
end