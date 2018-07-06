function frames = initFrames(num)
%initFrames Initializes an array of frame objects

frames(num).id = num;
for ii=1:num
    frames(ii).id   = ii;
    frames(ii).rej  = false;
    frames(ii).pcc  = 0;
    frames(ii).xy   = [0,0];
    frames(ii).link_id = 0;
    frames(ii).cluster = 0;
end
frames = frames';
end