function frames = initFrames(num)
%initFrames Initializes an array of frame objects

frames(num).id = num;
for ii=1:num
    frames(ii).id   = ii;
    frames(ii).rej  = false;
end
frames = frames';
end