function varargout = labeller(varargin)
% LABELLER MATLAB code for labeller.fig
%      LABELLER, by itself, creates a new LABELLER or raises the existing
%      singleton*.
%
%      H = LABELLER returns the handle to a new labeller or the handle to
%      the existing singleton*.
%
%      LABELLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELLER.M with the given input arguments.
%
%      LABELLER('Property','Value',...) creates a new LABELLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labeller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labeller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labeller

% Last Modified by GUIDE v2.5 04-Dec-2016 21:38:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labeller_OpeningFcn, ...
                   'gui_OutputFcn',  @labeller_OutputFcn, ...
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


% --- Executes just before labeller is made visible.
function labeller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labeller (see VARARGIN)

% Choose default command line output for labeller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(gcf,'WindowButtonDownFcn',@(object, eventdata) myButtonDownFcn(object, eventdata, handles))
evalin('base', 'clear');

% initialize modules as off
set(handles.listbox1,'Enable','on'); % label new
set(handles.pushbutton1,'Enable','off'); % label new
set(handles.pushbutton2,'Enable', 'off'); % undo
set(handles.pushbutton4,'Enable', 'off'); % add event
set(handles.pushbutton5,'Enable', 'off'); % finish set
set(handles.slider2, 'Enable', 'off');
set(handles.slider3, 'Enable', 'off');

% UIWAIT makes labeller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = labeller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% active:
% []: no dataset selected for labelling
% 0: no event being created.
% 1: event being created.

%global current_event; % 3 x 1 array of indices corresponding to cooking event currently being labeled: 
% [start_of_lighting, end_of_lighting, end_of_cooking]
%global events; % matrix of cooking event indices. each row corresponds to a cooking event


% get selected file
items = get(hObject,'String');
index_selected = get(hObject,'Value');
item_selected = items{index_selected};
%display(item_selected);

if isActive()
    choice = questdlg('Are you sure you want to exit this data set? All of your work will be lost.', 'Clear Workspace', 'Yes', 'Cancel', 'Yes');
    switch choice
        case 'Yes'
            evalin('base', 'clear');
        case 'Cancel'
            return
    end
end

% add 'Loading ...' message
%loading = uicontrol('Style', 'text', 'String', 'Loading ... ', 'Position', [.5, .5, 0, 0]); 
%loading = annotation('textbox', [.5, .5, .1, .1], 'String', 'Loading ...');

log_rate = 4.58; %%% make RFC
[all_data, total_days] = load_SUM(item_selected, log_rate);

% delete 'Loading ...' message
%delete(loading);

% use dialog boxes to get day range, then load file
start_day = str2double(inputdlg('Input start day'));
while start_day < 1 || start_day > total_days || (start_day - floor(start_day) ~= 0)
    waitfor(msgbox(strcat('Start index must be an integer in the range [1,', num2str(floor(total_days)), ']')))
    start_day = str2double(inputdlg('Input start day'));
end
end_day = str2double(inputdlg('Input end day'));
while end_day <= start_day || end_day > total_days || (end_day - floor(end_day) ~= 0)
    waitfor(msgbox(strcat('End index must be an integer in the range (', num2str(start_day), ', ', num2str(floor(total_days)), ']')))
    end_day = str2double(inputdlg('Input end day'));
end

% % get time and data vectors
samples_per_day = (1 / log_rate) * 60 * 24;
start_index = floor(samples_per_day * start_day);
end_index = floor(samples_per_day * end_day) - 1;
data = all_data(start_index : end_index);
n = length(data);
time = ones(1, n)*start_day + (1:n)/n * (end_day - start_day - 1/samples_per_day);

%[time, data] = all

plot(time, data);
title(strcat('File: ', item_selected, '     Start Day:', num2str(start_day), '  End day: ' , num2str(end_day)));

set(handles.axes1, 'XLim', [start_day, end_day])
%set(handles.axes1, 'YLim', [0, 1])

% initialize slider values
center = start_day + (time(length(time)) - start_day)/2;
% zoom
set(handles.slider3, 'Value', 0); % all the way zoomed out
% shift
set(handles.slider2, 'Value', .5); % centered
dayRange = [start_day, end_day];

% initialize module
set(handles.pushbutton1,'Enable','on'); % label new
set(handles.pushbutton2,'Enable', 'off'); % undo
set(handles.pushbutton4,'Enable', 'off'); % add event
set(handles.pushbutton5,'Enable', 'off'); % finish set
set(handles.slider2, 'Enable', 'on');
set(handles.slider3, 'Enable', 'on');

active = 0;

% save variables in workspace
assignin('base', 'active', active);
assignin('base', 'data', data);
assignin('base', 'dayRange', dayRange);
assignin('base', 'center', center);
assignin('base', 'filename', item_selected);
assignin('base', 'events', []);

%set(gcf, 'WindowButtonMotionFcn', @(object, eventdata) mouseMove(object, eventdata, handles))

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% SHIFTER
% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isActive()
    return
end

%if ~isequal(active, [])
center = evalin('base', 'center');
dayRange = evalin('base', 'dayRange');

xlimits = get(handles.axes1, 'XLim');
xmin = xlimits(1);
xmax = xlimits(2);
start_day = dayRange(1);
end_day = dayRange(2);
window_width = xmax - xmin;
slider_position = get(hObject, 'Value');
center = start_day + (end_day - start_day) * slider_position; % day to center at
set(handles.axes1, 'XLim', [center - window_width/2, center + window_width / 2]);

% update center of window
assignin('base', 'center', center);

% if center - window_width/2 < xmin
%     center = xmin + window_width/2;
% end
% if center + window_width/2 > xmax
%     center = xmax - window_width/2
% end
% if (center) >= dayRange(1) && (center <= dayRange(2))
%     set(handles.axes1, 'XLim', [center - window_width/2, center + window_width / 2]);
% else
%     set(hObject, 'Value', (center - xmin) / window_width); % don't move slider if no window shift
% end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% ZOOM ZOOM ZOOM!
% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isActive()
    return
end

center = evalin('base', 'center');
dayRange = evalin('base', 'dayRange');
numDays = dayRange(2) - dayRange(1);

slider_position = get(hObject, 'Value');
scale_fac = 2 ^ (5 * slider_position);
%xlimits = get(handles.axes1, 'XLim');
%xmin = xlimits(1);
%xmax = xlimits(2);
%half_width = (xmax - xmin) / 2;
set(handles.axes1, 'XLim', [center - numDays/2/scale_fac, center + numDays/2/scale_fac]);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% pushbutton1: create new cooking event
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if ~isActive()
%     return
% end

active = evalin('base', 'active');

% start new event
if active == 0;
    active = 1;
    current_event = [-1, -1, -1]; % initialize
end

% update
assignin('base', 'active', active);
assignin('base', 'current_event', current_event);
assignin('base', 'cel', [0, 0, 0, 0, 0]);



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1



% global active;
% global current_event
% if inBounds(handles)
%     if isequals(active, 1)
%         C = get(gca, 'CurrentPosition');
%         current_event(1) = day_to_index(C(1, 1))
%     end
% end

% pushbutton2: UNDO
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_event = evalin('base', 'current_event');
cel = evalin('base', 'cel');

% last line = end of cooking event
if current_event(3) ~= -1
    current_event(3) = -1;
    delete(cel(5));
    delete(cel(4));
    set(handles.pushbutton4, 'Enable', 'off'); % disable 'add to target set'
% last line = end of lighting event
elseif current_event(2) ~= -1
    current_event(2) = -1;
    delete(cel(3));
    delete(cel(2));
% last line = start of lighting
elseif current_event(1) ~= -1
    current_event(1) = -1;
    delete(cel(1));
    set(handles.pushbutton2, 'Enable', 'off'); % disable undo.
end

assignin('base', 'current_event', current_event);
assignin('base', 'cel', cel);


%pushbutton4: add event to target set
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% active = evalin('base', 'active');
% if ~active
%     return
% end

events = evalin('base', 'events');
current_event = evalin('base', 'current_event');

%choice = questdlg('Are you want to add this event? Once added, it cannot be removed.', 'Yes');
% switch choice
%     case 'Yes'
        if isequal(events, [])
            events = current_event;
            set(handles.pushbutton5, 'Enable', 'on'); % complete set
        else
            events = vertcat(events, current_event);
        end
        
active = 0;
assignin('base', 'active', active);
assignin('base', 'events', events);
assignin('base', 'current_event', [-1, -1, -1]);
set(hObject, 'Enable', 'off');
set(handles.pushbutton1, 'Enable', 'on'); % enable creat new
% end
        

% save target set
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = evalin('base', 'filename');
events = evalin('base', 'events');
data = evalin('base', 'data');
dayRange = evalin('base', 'dayRange');

choice = questdlg('Are you are finished? Once you save, you cannot add to or edit this target set.', 'Complete Target Set', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        name_cell = inputdlg('Please enter a name for this training set.');
        name = name_cell{:};
        
        set = compile_training_set(data, events);
        start_day = dayRange(1);
        end_day = dayRange(2);
        save(strcat(name, '.mat'), 'set' , 'filename', 'start_day', 'end_day');
        evalin('base', 'clear');
    case 'No'
        
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
