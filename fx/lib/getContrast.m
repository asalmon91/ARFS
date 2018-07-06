function data = getContrast(imgs, data, wb)
%getContrast 

% Waitbar
waitbar(0, wb, 'Measuring image contrast');

con = zeros(size(data));
for ii=1:numel(data)
    if data(ii).rej
        continue;
    end
    
    img = double(imgs(:,:,ii));
    con(ii) = std(img(:))./mean(img(:));
    
    waitbar(ii/numel(data), wb);
end
con([data.rej]) = [];


con_norm = (con - mean(con))./std(con);
badFrames = find(con_norm < -3);
if ~isempty(badFrames)
    rejectFrames(data, badFrames, mfilename);
end

end

