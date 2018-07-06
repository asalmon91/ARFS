function [uid_sort, link_sz] = sortLink_id_bySize(data)
[unique_id, ~, ic] = unique([data([data.link_id]~=0).link_id]);
link_sz = zeros(size(unique_id));
for ii=1:numel(unique_id)
    link_sz(ii) = numel(find(ic==ii));
end
[~, I] = sort(link_sz, 'descend');
uid_sort = unique_id(I);
end