function [ data ] = getClusters(data, wb)
%getClusters Returns clusters of stable fixation
%   Uses kmeans and slihouette value optimization to pick the "best" number
%   of clusters.

% Waitbar
waitbar(0, wb, 'Clustering frames...');
% todo: figure out why we're getting an infinite loop
% Get initial clustering
link_sort = sortLink_id_bySize(data);
for ii=1:numel(link_sort)
    linked = [data([data.link_id] == link_sort(ii)).id];
    data = getInitialClustering(data, linked);
    
    waitbar(ii/numel(link_sort), wb)
end

% Waitbar
waitbar(0, wb, 'Absorbing clusters...');

% Absorb clusters that overlap by >= 75%
for ii=1:numel(link_sort)
    % Find largest cluster index
    cluster_sort = sortClusterBySize(data, link_sort(ii));
    if numel(cluster_sort) == 1
        continue;
    end
    
    % Get centroid
    
    linked = [data([data.link_id] == link_sort(ii)).id];
    xy = getAllXY(data(linked));
    
    for jj=1:numel(link_sort)
    
    end
    
    waitbar(ii/numel(link_sort), wb);
end

% Reject small clusters




% mfpc = data(1).MFPC;
% uniqueGroups = unique([data(~[data.rej]).link_id]);
% nGroups = numel(uniqueGroups);
% data.clusters(nGroups).groupName 	= [];
% data.clusters(nGroups).cNames   	= [];
% data.clusters(nGroups).assign       = [];
% data.clusters(nGroups).frames       = [];
% data.clusters(nGroups).sizes        = [];
% data.clusters(nGroups).centroids    = [];
% data.clusters(nGroups).xy           = [];
% data.rejected.smallClusters         = [];

xyt = [data.x, data.y];
for i=1:numel(uniqueGroups)
    
    waitbar(i/numel(uniqueGroups),wb,'Clustering...');
    
    thisGroup  = data.saccades==uniqueGroups(i);
    
    data.clusters(i).groupName = uniqueGroups(i);
    data.clusters(i).frames = data.frames(thisGroup);
    
    xy = xyt(thisGroup,:);
    data.clusters(i).xy = xy;
    
    nf = numel(find(thisGroup));
    % should never have to worry about this being 0 since anything less than mfpc was rejected in MT
    maxK = round(nf/mfpc);
    if maxK == 1 % all frames belong to the same cluster, don't bother kmeans with this nonsense
        data.clusters(i).assign     = ones(nf,1);
        data.clusters(i).cNames     = 1;
        data.clusters(i).sizes      = nf;
        data.clusters(i).centroids  = mean(xy,1);
        continue;
    end
    evalSilhouette = evalclusters(xy,'kmeans','silhouette','KList',1:maxK);
    
    % Ensure biggest cluster exceeds size threshold
    optK = evalSilhouette.OptimalK;
    tblSilh = 0;
    while max(tblSilh) <= mfpc
        clusterSilhouette = kmeans(xy,optK,'replicates',5);
        optK = optK - (max(tblSilh) <= mfpc);
        tblSilh = tabulate(clusterSilhouette);
        tblSilh = tblSilh(:,2);
    end
    
    data.clusters(i).cNames = unique(clusterSilhouette);
    nc = numel(data.clusters(i).cNames);
    data.clusters(i).assign = clusterSilhouette;
    data.clusters(i).sizes  = tblSilh;
    data.clusters(i).centroids = zeros(nc,2);

    % Steal frames
    data = clusterOverlap(data, data.clusters(i));
end

data = removeSmallClusters(data);

end

