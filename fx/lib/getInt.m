function data = getInt(imgs, data)
%getInt rejects frames with low intensity (mean-3*stdev) and fully 
% saturated frames % (sometimes happens with split frames)

%% Get mean intensity
mInt = mean(squeeze(mean(imgs,1)),1)';

%% Find outliers
mIntNorm = (mInt - mean(mInt))./std(mInt);
badFrames = mIntNorm < -3 | mInt == 255;

data = rejectFrames(data, badFrames, mfilename);

end