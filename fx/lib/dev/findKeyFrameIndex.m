function index = findKeyFrameIndex(data, link)
    ids     = [data([data.link_id] == link).id];
    [~,I]   = max([data([data.link_id] == link).pcc]);
    index   = ids(I);
    if numel(index) > 1
        index = index(1);
    end
end

