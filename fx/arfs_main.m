function frames = arfs_main(vid, varargin)
% arfs estimates the ... (todo) finish the intro
% vid must be a 3D matrix of size [height, width, #frames]
% outputs the frames structure with length==#frames. Each frame object has
% the properties: number, rank, group, cluster, coord, rej, and rej_method.


%% Imports
addpath('.\lib');

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

try
    %% Construct frame objects
    frames = initFrames(size(vid,3));
    
    %% Reject frames based on mean intensity
    frames = getInt(vid, frames, wb);
    
    %% STEP 3: INTRA-FRAME MOTION-BASED SCORING
    arfs_data = getIFM(vid, arfs_data, wb);

    %% STEP 4: TRACK MOTION
    % Set up search window for NCC: 2/3 ht wd
    arfs_data.searchWinSize = round(2/3.*arfs_data.size);
    arfs_data = getMT(vid, arfs_data, wb); % will only do 1st pass if mtskip
    
    %% STEP 5: CLUSTER ANALYSIS OF FIXATIONS
    if ~arfs_data.mtskip
        arfs_data = getClusters(arfs_data, wb);
        arfs_data = getP2C(arfs_data, wb);
    else
        arfs_data.rejected.outliers_P2C = [];
    end
    
    %% STEP 6: SORTING/REPORTING
    arfs_data = finalRejection(arfs_data);
    arfs_data.finalScores = arfs_data.scores.sumRsqs;
    
    waitbar(1,wb,strrep(sprintf('Done analyzing %s',arfs_data.name),'_','\_'));
                        
%% Error Handling
catch MException
    fprintf('\nI''m sorry I failed you: %s\n', parameters.fname);
    fprintf(MException.message);
    fprintf('\n');
    arfs_data = MException;
end
end





