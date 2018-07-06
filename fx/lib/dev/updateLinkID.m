function data = updateLinkID(data, ids, link_id)
for ii=1:numel(ids)
    data(ids(ii)).link_id = link_id;
end
end

