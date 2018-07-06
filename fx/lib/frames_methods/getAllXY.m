function xy = getAllXY(frames)
%getAllXY returns the xy fields from a frames structure as an mx2 array

xy = zeros(numel(frames),2);
for ii=1:numel(frames)
    xy(ii,:) = frames(ii).xy;
end
end

