function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 01-Jan-2015 22:53:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Initialize variables
%handles.vid = [];       % Video
handles.curFrame = 1;   % Current frame
handles.playtime = 0;   % Total time since starting the video

% Load template images of characters
handles.charImgs = loadImages();

% Hide axis
axes(handles.axes1);
axis off;
set(gca, 'xtick',[],'ytick',[]);
text (0.1, .9, '<Cool plaatje hier>');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in import.
function import_Callback(hObject, eventdata, handles)
% hObject    handle to import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open file browser
[file path] = uigetfile('*.avi','Import the video');

% Check if file is selected
if ~isequal(file, 0) || ~isequal(path, 0)
    % Get the video
    handles.vid = VideoReader([path file]);
    
    % Set focus to axes1
    axes(handles.axes1);
    
    % Read the first frame and set the image
    image(read(handles.vid, 1));

    % Hide axis
    axis off;
    set(gca, 'xtick',[],'ytick',[]);
    
    % Store structure
    guidata(hObject, handles);
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Note: The start/pause processing button is a Toggle button and controls
% if the video is playing

if ~get(handles.start,'Value')
    button_pause(hObject, handles);
else
    button_start(hObject, handles);
    startProcessing(hObject, eventdata, handles);
end;


function startProcessing(hObject, eventdata, handles)
% Set focus to axes1
axes(handles.axes1);

% Get the number of frames and the rate
frames = handles.vid.numberOfFrames;
rate = handles.vid.FrameRate;

% Start the counter time in ms (to play at specified frames per second)
tic;
time = 0;

licenseCounter = {}; % Store how often a license plate is detected
                     % Format: lC{1} = {'xx-xx-xx', 1}

while get(handles.start,'Value') && handles.curFrame < frames
    % Store when this cycle starts and set current frame
    time = toc;
    handles.curFrame = handles.curFrame + 7;
    i = handles.curFrame;   % Shorter variable for the current frame
    
    % Read frame and update in GUI
    frame = read(handles.vid, i);
    h = get(handles.axes1, 'Children');
    set(h, 'CData', frame);
    
    % Process the frame
    plate = processFrame(frame, handles.charImgs);
    if (~isempty(plate))
        % If it returns something, add a new row
        data = get(handles.table, 'Data');
        
         % Check if it has already been found
%         found = false;
%         maxDiff = 0; % Find the maximum difference for every string
%         for i = 1:size(licenseCounter, 2)
%             diff = 
%             if strcmp(plate, licenseCounter{i}(1))
%                 found = true;
%                 licenseCounter{i}(2) = licenseCounter{i}(2) + 1;
%                 break;
%             end;
%         end;
        
        % Add everything that is recognized
        if isempty(data)
            data(end+1, :) = {plate i (time + handles.playtime)};
            set(handles.table, 'Data', data);
        else
            prevEntry = data(end, :);
            if ~strcmp(prevEntry{1}, plate)
                data(end+1, :) = {plate i (time + handles.playtime)};
                set(handles.table, 'Data', data);
            else
                % If it finds the same result as the last one, don't add it
                % and skip a few frames
                handles.curFrame = handles.curFrame + 1;
            end;
        end;
    end;
    
    % Update time and frame no. in GUI
    set(handles.frame, 'String', ['Frame: ' num2str(i)]);
    set(handles.time, 'String', ['Time: ' num2str(floor(handles.playtime + time)) ' - avg. time: ' num2str(round(1000*(handles.playtime + time)/i))]);
    
    % Set timeline position
    pos = get(handles.timeline, 'Position');
    pos(1) = -pos(3) + pos(3) * (i/frames);
    set(handles.timeline, 'Position', pos);

    % Pause if time between frames is lower than 1/framerate
%     while (handles.playtime + toc < handles.playtime + 1/rate) 
%     end;
    
    % Save the current state in the GUI structure
%     guidata(hObject, handles);
end;

% When the video has stopped playing or is paused
if handles.curFrame == frames 
    % If it has finished playing
    stop(hObject, handles);
else % If video is paused
    button_pause(hObject, handles);         % Set the button to pause state
    handles.playtime = handles.playtime + time; % Store the total playtime
    guidata(hObject, handles); % Store play time
end;

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(hObject, handles);

% --- Sets the play/pause button to the paused state and resets gui & variables
function stop(hObject, handles)
 % Reset timeline position
pos = get(handles.timeline, 'Position');
pos(1) = -pos(3);
set(handles.timeline, 'Position', pos);

axes(handles.axes1);    % Set focus to axes1
% Read first frame and update in GUI
frame = read(handles.vid, 1);
h = get(handles.axes1, 'Children');
set(h, 'CData', frame);

% Reset variables
handles.curFrame = 1;
handles.playtime = 0;
button_pause(hObject, handles);
guidata(hObject, handles);

% --- Sets the play/pause button to the playing state
function button_start(hObject, handles)
set(handles.start,'Value', true)
set(handles.start, 'String', 'Pause processing');
guidata(hObject, handles);

% --- Sets the play/pause button to the paused state
function button_pause(hObject, handles)
set(handles.start,'Value', false)
set(handles.start, 'String', 'Start processing');
guidata(hObject, handles);

function res = loadImages(hObject, handles)
characters = '0123456789BDFGHJKLMNPRSTVXZ';

imgs = {};

filePath = mfilename('fullpath');
dir = filePath(1:length(filePath)-3);

for i=1:length(characters)
    img = imread([dir 'Characters\' characters(i) '.png']);
    img = img(:, :, 1) < 128;
    imgs{i} = (img);
end;
res = imgs;
