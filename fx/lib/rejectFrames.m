function data = rejectFrames(data, bf, method)
%removeFrames changes the rej field to true
% bf can be an array of frame indices or a logical array, it indicates
% which frames to reject
% method is a string indicating which method rejected the frame

if islogical(bf)
    bf = find(bf);
end
    
for ii=1:numel(bf)
    data(bf(ii)).rej = true;
    data(bf(ii)).rej_method = method;
end
end