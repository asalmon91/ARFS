function data = updateCluster(data, indices, cluster_number)
%updateCluster Sets the cluster assignment for the frames defined by
%indices
for ii=1:numel(indices)
    data(indices(ii)).cluster = cluster_number(ii);
end
end

