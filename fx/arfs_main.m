function frames = arfs_main(vid, varargin)
% arfs estimates the ... (todo) finish the intro
% vid must be a 3D matrix of size [height, width, #frames]
% outputs the frames structure with length==#frames. Each frame object has
% the properties: number, rank, group, cluster, coord, rej, and rej_method.

%% Imports
% Add ARFS library and subfolders
addpath(genpath('.\lib'));

%% Parse inputs
% defaults: arfs_main(vid, 'TrackMotion', true, 'MFPC', 10)
TRACK_MOTION = true;
MFPC = 10; % Minimum frames per cluster
if nargin > 1
    %TRACK_MOTION
    tm_input = strcmpi(varargin, 'trackmotion');
    if ~isempty(tm_input)
        TRACK_MOTION = varargin{find(tm_input)+1};
    end
    
    % MFPC
    mfpc_input = strcmpi(varargin, 'mfpc');
    if ~isempty(mfpc_input)
        MFPC = varargin{find(mfpc_input)+1};
    end
end

%% Construct frame objects
frames = initFrames(size(vid,3));
frames(1).TRACK_MOTION = TRACK_MOTION;
frames(1).MFPC = MFPC;

%% Reject frames based on mean intensity, contrast, and sharpness
frames = getInt(vid, frames);
frames = getContrast(vid, frames, wb);
frames = getSharpness(vid, frames, wb);

%% Intra-frame motion detection
% arfs_data = getIFM(vid, arfs_data, wb);

%% Inter-frame motion detection
% Will only do 1st pass if TRACK_MOTION is false
frames = getMT(vid, frames, TRACK_MOTION, MFPC, wb);

%% STEP 5: CLUSTER ANALYSIS OF FIXATIONS
if frames(1).TRACK_MOTION
    frames = getClusters(frames, wb);
    frames = getP2C(frames, wb);
end

end





