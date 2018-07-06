function regSeq = getRegSeq(mat3d, tforms)
%getRegSeq Returns a registered image sequence

regSeq = zeros(...
    ceil(max(tforms(:,2)) - min(tforms(:,2)) + size(mat3d,1) +1), ...
    ceil(max(tforms(:,1)) - min(tforms(:, 1)) + size(mat3d, 2) +1), ...
    size(mat3d,3), 'uint8');

tforms_gspace = tforms; % global space
tforms_gspace(:,1) = tforms_gspace(:,1) - min(tforms(:,1))+1;
tforms_gspace(:,2) = tforms_gspace(:,2) - min(tforms(:,2))+1;
tforms_gspace      = round(tforms_gspace);

for ii=1:size(mat3d,3)
    regSeq(...
        tforms_gspace(ii,2):tforms_gspace(ii,2)+size(mat3d,1)-1, ...
        tforms_gspace(ii,1):tforms_gspace(ii,1)+size(mat3d,2)-1, ...
        ii) = mat3d(:,:,ii);
end


end

