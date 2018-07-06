function [cluster_sort] = sortClusterBySize(data,link_id)
%sortClusterBySize returns the cluster ids sorted by number of frames with
%that id

clusters = [data([data.link_id] == link_id).cluster];
[u_clusters,~,ic] = unique(clusters);
if numel(u_clusters) == 1
    cluster_sort = u_clusters;
    return;
end
cluster_sz = zeros(size(u_clusters));
for ii=1:numel(u_clusters)
    cluster_sz(ii) = numel(find(ic==ii));
end
[~, I] = sort(cluster_sz, 'descend');
cluster_sort = u_clusters(I);


end

