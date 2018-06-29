function data = getInt(imgs, data)
%getInt rejects frames with low intensity (µ-3?) and fully saturated frames
% (sometimes happens with split frames)

%% Get mean intensity
mInt = mean(squeeze(mean(imgs,1)),1)';

%% Find outliers
mIntNorm = (mInt - mean(mInt))./std(mInt);
badFrames = mIntNorm < -3 | mInt == 255;

%% Update reject and score information, reject frames
data.rejected.outliers_INT = data.frames(badFrames);
data.scores.int = prepScore(mInt,'dir');
data = removeFrames(data,badFrames);

end