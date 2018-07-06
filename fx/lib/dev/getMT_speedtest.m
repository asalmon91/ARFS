%% getMT speed and accuracy test

vid_tmp = vid;
frames_tmp = initFrames(size(vid_tmp,3));

t_new = 0; %#ok<*NASGU>
t_old = 0;
tic
frames_new = getMT(vid_tmp,frames_tmp,TRACK_MOTION,MFPC,wb);
t_new = toc;

% Set up old input
images = cell(size(vid_tmp,3),1);
for ii=1:numel(images)
    images{ii} = im2double(vid(:,:,ii));
end
d.frames = 1:numel(frames_tmp);
d.scores.sumRsqs = zeros(size(d.frames));
d.scores.int = d.scores.sumRsqs;
d.size = size(vid_tmp(:,:,1));
d.searchWinSize = (2/3).*d.size;
d.minFramesPerCluster = MFPC;
tic
frames_old = getMT_old(images,d,wb);
t_old = toc;
frames_old.x = frames_old.x.*-1;

regSeq_old = getRegSeq(vid_tmp(:,:,frames_old.frames),...
    [frames_old.x,frames_old.y]);
regSeq_new = getRegSeq(vid_tmp(:,:,[frames_new(~[frames_new.rej]).id]), ...
    getAllXY(frames_new(~[frames_new.rej])));

vid_path = 'C:\Users\DevLab_811\Documents\Code\AO\AO-PIPE\tests\datasets\0-13LGS\reg';
fn_write_AVI(fullfile(vid_path, 'old.avi'), regSeq_old, 16, wb);
fn_write_AVI(fullfile(vid_path, 'new.avi'), regSeq_new, 16, wb);



