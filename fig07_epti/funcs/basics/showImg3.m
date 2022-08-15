function varargout = showImg3(varargin)
% SHOWIMG3 MATLAB code for showImg3.fig
%      SHOWIMG3, by itself, creates a new SHOWIMG3 or raises the existing
%      singleton*.
%
%      H = SHOWIMG3 returns the handle to a new SHOWIMG3 or the handle to
%      the existing singleton*.
%
%      SHOWIMG3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWIMG3.M with the given input arguments.
%
%      SHOWIMG3('Property','Value',...) creates a new SHOWIMG3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showImg3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showImg3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showImg3

% Last Modified by GUIDE v2.5 02-Apr-2014 19:54:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showImg3_OpeningFcn, ...
                   'gui_OutputFcn',  @showImg3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before showImg3 is made visible.
function showImg3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showImg3 (see VARARGIN)

% Choose default command line output for showImg3
handles.output = hObject;

handles.data=varargin{1};
handles.type=varargin{2};
handles.combine=varargin{3};
handles.scale=varargin{4};

Im=trans(handles.data(:,:,1,:),handles.type,handles.combine);
if strcmp(handles.scale,'default')
    handles.scale=[0,norm(Im(:))/sqrt(numel(Im))*2];
end
axes(handles.axes1);
imshow(abs(Im),handles.scale);
dim3=size(handles.data,3);
set(handles.slider1,'Min',1, 'Max',dim3,...
    'SliderStep', [1/(dim3-1), 1/(dim3-1)],'Value',1);
handles.dim3=dim3;
    handles.img{1}=Im;
for fr=2:dim3
    handles.img{fr}=[];
end
% Update handles structure
guidata(hObject, handles);

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


% UIWAIT makes showImg3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = showImg3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
frame=str2num(get(hObject,'String'));
frame=round(frame);
if frame>handles.dim3
    frame=handles.dim3;
elseif frame<1
    frame=1;
end
set(hObject,'String',num2str(frame))
set(handles.slider1,'value',frame);
handles=updateimg(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
frame=get(hObject,'value');
frame=round(frame);
if frame>handles.dim3
    frame=handles.dim3;
elseif frame<1
    frame=1;
end
set(handles.edit1,'String',num2str(frame))
set(handles.slider1,'value',frame);
handles=updateimg(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function handles=updateimg(hObject,handles)
frame=get(handles.slider1,'value');
if length(handles.img{frame})
    Im=handles.img{frame};
else
    Im=trans(handles.data(:,:,frame,:),handles.type,handles.combine);
    handles.img{frame}=Im;
end
axes(handles.axes1);
imshow(abs(Im),handles.scale);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
type=get(hObject,'value');
switch type
    case 2
        set(handles.text1,'visible','off');
        set(handles.edit1,'visible','off');
        set(handles.slider1,'visible','off');
        handles=updateimgt(handles);
    case 1
        set(handles.text1,'visible','on');
        set(handles.edit1,'visible','on');
        set(handles.slider1,'visible','on');
        handles=updateimg(hObject,handles);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isvisible=get(handles.text1,'visible');
set(handles.text1,'visible','on');
set(handles.edit1,'visible','on');
set(handles.slider1,'visible','on');
for fr=1:handles.dim3
    set(handles.edit1,'string',num2str(fr));
    set(handles.slider1,'value',fr);
    handles=updateimg(hObject,handles);
end
set(handles.text1,'visible',isvisible);
set(handles.edit1,'visible',isvisible);
set(handles.slider1,'visible',isvisible);
if strcmp(isvisible,'off')
    handles=updateimgt(handles);
end
guidata(hObject,handles);

function handles=updateimgt(handles)
    for frame=1:handles.dim3
        if length(handles.img{frame})==0
            Im=trans(handles.data(:,:,frame,:),handles.type,handles.combine);
            handles.img{frame}=Im;
        end
    end
    [nfe,npe]=size(handles.img{1});
    x=ceil(sqrt(handles.dim3));
    y=ceil(handles.dim3/x);
    Im=zeros(y*nfe,x*npe);
    for frame=1:handles.dim3
        fe=floor((frame-1)/x)*nfe;
        pe=mod(frame-1,x)*npe;
        Im(fe+1:fe+nfe,pe+1:pe+npe)=handles.img{frame};
    end
    axes(handles.axes1);
    imshow(abs(Im),handles.scale);
