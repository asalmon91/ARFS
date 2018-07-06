function data = getMT(imgs, data, fullMT, mfpc, wb)
%getMT tracks interframe motion in a video

% default phase correlation threshold is 0.03
% empirical testing so far, suggests 0.015 would be better
PCC_THR = 0.015;

%% 1st pass: Estimate translations between frame pairs
waitbar(0, wb, 'Calculating Phase Correlation Coefficients');

% Get indices of fixed and moving frames
fix_id = [data(~[data.rej]).id]';
mov_id = fix_id;
fix_id = fix_id(1:end-1);
mov_id = mov_id(2:end);
link_id = 1;
for ii=1:numel(fix_id)
    if ii==1
        [tform, pcorr, fftfix] = getPhaseCorr(...
            single(imgs(:,:,fix_id(ii))), ...
            single(imgs(:,:,mov_id(ii))));
    else
        [tform, pcorr, fftfix] = getPhaseCorr(...
            fftfix, ...
            single(imgs(:,:,mov_id(ii))));
    end
    
    % Update PCC and coordinates
    data = updatePCC(data, fix_id(ii), mov_id(ii), pcorr);
    if pcorr > PCC_THR
        % linked
        data(fix_id(ii)).link_id = link_id;
        data(mov_id(ii)).link_id = link_id;
    else
        link_id = link_id+1;
    end
    data(mov_id(ii)).xy = data(fix_id(ii)).xy + tform.T(3,1:2);
    
    % waitbar
    waitbar(ii/numel(fix_id), wb);
end

% End of 1st pass
if ~fullMT || isempty(data([data.pcc] < PCC_THR & ~[data.rej]))
    return;
end

%% Start of 2nd pass
% Waitbar
waitbar(0, wb, 'Correcting breaks in sequence...');

% For each linked group of frames (from largest to smallest), try to absorb
% other linked groups by comparing the frames with the highest pcc in each
link_sorted = sortLink_id_bySize(data);
absorbed = false(size(link_sorted));
for ii=1:numel(link_sorted)
    if absorbed(ii)
        continue;
    end
    % Find frame in this link group with highest pcc
    fix_id = findKeyFrameIndex(data, link_sorted(ii));
    for jj=1:numel(link_sorted)
        if jj<=ii || absorbed(jj)
            first_iter = true;
            continue;
        end
        mov_id = findKeyFrameIndex(data, link_sorted(jj));
        if first_iter
            [tform, pcorr, ~, fftfix] = getPhaseCorr(...
                single(imgs(:,:,fix_id)), ...
                single(imgs(:,:,mov_id)));
            first_iter = false;
        else
            [tform, pcorr] = getPhaseCorr(...
                fftfix, ...
                single(imgs(:,:,mov_id)));
        end
        
        % Update PCC, coordinates, linked
        data = updatePCC(data, fix_id, mov_id, pcorr);
        
        if pcorr > PCC_THR
            absorbed(jj) = true;
            linked = [data([data.link_id] == link_sorted(jj)).id];
            data = updateXY(data, fix_id, mov_id, tform, linked);
            data = updateLinkID(data, linked, link_sorted(ii));
            break;
        end
    end
    
    % Waitbar
    waitbar(ii/numel(link_sorted), wb);
end

%% Start of 3rd pass
% Waitbar
waitbar(0, wb, 'Registering unlinked frames...');

% Register unlinked frames to key frame in each linked group, proceed
% largest to smallest
link_sorted = sortLink_id_bySize(data);
unlinked = [data([data.link_id] == 0 & ~[data.rej]).id];
absorbed = false(size(unlinked));
for ii=1:numel(link_sorted)
    fix_id = findKeyFrameIndex(data, link_sorted(ii));
    first_iter = true;
    for jj=1:numel(unlinked)
        if absorbed(jj)
            continue;
        end
        mov_id = unlinked(jj);
        if first_iter
            [tform, pcorr, ~, fftfix] = getPhaseCorr(...
                single(imgs(:,:,fix_id)), ...
                single(imgs(:,:,mov_id)));
            first_iter = false;
        else
            [tform, pcorr] = getPhaseCorr(...
                fftfix, ...
                single(imgs(:,:,mov_id)));
        end
        if pcorr > PCC_THR
            absorbed(jj) = true;
            data = updatePCC(data, fix_id, mov_id, pcorr);
            data(unlinked(jj)).link_id = link_sorted(ii);
            data(unlinked(jj)).xy = data(fix_id).xy + tform.T(3,1:2);
            break;
        end
    end
    
    % Waitbar
    waitbar(ii/numel(link_sorted), wb);
end
% End of 3rd Pass

%% Check if largest group of linked frames is smaller than mfpc
[~, link_sz] = sortLink_id_bySize(data);
if max(link_sz) < mfpc
    data(1).TRACK_MOTION = false;
    data(1).TRACK_MOTION_FAILED = true;
    
    warning('Failed to link more than %i frames together.', mfpc);
    return;
end

%% Reject small groups and PCC outliers
% Small groups
data = rejectSmallGroups(data, mfpc);
% PCC outliers
pcc = [data(~[data.rej]).pcc];
ids = [data(~[data.rej]).id];
pcc_norm = (pcc - mean(pcc))./std(pcc);
outliers = pcc_norm < -3;
if any(outliers)
    rejectFrames(data, ids(outliers), mfilename)
end

end % End of MT
% 
% function data = updatePCC(data, fix, mov, pcorr)
% % updatePCC only updates the PCC of a frame if the new value is higher than
% % the old value
%     if data(fix).pcc < pcorr
%         data(fix).pcc = pcorr;
%     end
%     if data(mov).pcc < pcorr
%         data(mov).pcc = pcorr;
%     end
% end
% 
% function data = updateXY(data, fix_id, mov_id, tform, linked)
% for ii=1:numel(linked)
%     data(linked(ii)).xy = data(linked(ii)).xy - data(mov_id).xy + ...
%         data(fix_id).xy + tform.T(3,1:2);
% end
% end
% 
% function index = findKeyFrameIndex(data, link)
%     ids     = [data([data.link_id] == link).id];
%     [~,I]   = max([data([data.link_id] == link).pcc]);
%     index   = ids(I);
%     if numel(index) > 1
%         index = index(1);
%     end
% end
% 
% function data = updateLinkID(data, ids, link_id)
% for ii=1:numel(ids)
%     data(ids(ii)).link_id = link_id;
% end
% end
% 
% function [uid_sort, link_sz] = sortLink_id_bySize(data)
% [unique_id, ~, ic] = unique([data([data.link_id]~=0).link_id]);
% link_sz = zeros(size(unique_id));
% for ii=1:numel(unique_id)
%     link_sz(ii) = numel(find(ic==ii));
% end
% [~, I] = sort(link_sz, 'descend');
% uid_sort = unique_id(I);
% end
% 
% function data = rejectSmallGroups(data, mfpc)
% rej = false(size(data));
% [uid_sort, link_sz] = sortLink_id_bySize(data);
% for ii=1:numel(data)
%     if data(ii).rej
%         continue;
%     end
%     % Reject all unlinked frames and groups smaller than mfpc
%     if data(ii).link_id == 0 || ...
%             link_sz(data(ii).link_id == uid_sort) < mfpc
%         rej(ii) = true;
%     end
% end
% 
% data = rejectFrames(data, rej, mfilename);
% end