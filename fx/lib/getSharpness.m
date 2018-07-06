function data = getSharpness(imgs, data, wb)
%getSharpness Computes the mean gradient magnitude of an image using a
%Sobel filter 

waitbar(0, wb, 'Calculating sharpness...');
sharps = zeros(numel(data), 1);
for ii=1:numel(data)
    if ~data(ii).rej
        sharps(ii) = mean(mean(sobelFilter(imgs(:,:,ii))));
    end
    
    waitbar(ii/numel(data), wb);
end

% Find outliers
sharps([data.rej]) = []; % Remove empty elements
sharps_norm = (sharps - mean(sharps))./std(sharps);
outliers = sharps_norm < -3;
% Get current list of kept frame ids
ids = [data(~[data.rej]).id];
rejectFrames(data,ids(outliers), mfilename);

end

