function data = getInitialClustering(data, indices)
%getInitialClustering 

maxK = floor(numel(indices)/data(1).MFPC);
if maxK <= 1
    data = updateCluster(data, indices, ones(size(indices)));
    return;
end

data = getInitialClustering(data, indices);
xy = getAllXY(data(indices));
evalSilhouette = evalclusters(xy,'kmeans',...
    'silhouette','KList',1:maxK);

% Ensure biggest cluster exceeds size threshold
optK = evalSilhouette.OptimalK;
tblSilh = 0;
while max(tblSilh) <= data(1).MFPC
    clusterSilhouette = kmeans(xy,optK,'replicates',5);
    optK = optK - (max(tblSilh) <= mfpc);
    tblSilh = tabulate(clusterSilhouette);
    tblSilh = tblSilh(:,2);
end

data = updateCluster(data, indices, clusterSilhouette);

end

