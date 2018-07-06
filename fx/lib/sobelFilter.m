function im_out=sobelFilter(im_in)
kx = [-1 0 1; -2 0 2; -1 0 1;];
ky  = [ -1 -2 -1; 0 0 0; 1 2 1;]; 
gx = conv2(im_in, kx, 'same');
gy = conv2(im_in, ky, 'same');
im_out = sqrt(gx.^2 + gy.^2);