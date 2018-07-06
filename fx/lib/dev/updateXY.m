function data = updateXY(data, fix_id, mov_id, tform, linked)
for ii=1:numel(linked)
    data(linked(ii)).xy = data(linked(ii)).xy - data(mov_id).xy + ...
        data(fix_id).xy + tform.T(3,1:2);
end
end

