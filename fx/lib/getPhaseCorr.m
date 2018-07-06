function [tform, pcorr, img2, img1] = getPhaseCorr(img1,img2)
%getPhaseCorr is a combination of features from imregcorr.m,
%findTranslationPhaseCorr.m, and phaseCorr.m. It's been stripped of all the
%fluff and safety features thanks to a few assumptions: img1 and img2 will
%be the same size, only translation is required, and subpixel registration
%is not necessary. Images should be blackman filtered before input to this
%function.

% either img can be input as the Fourier transform
if all(size(img1) ~= 2.*size(img2)-1)
    img1 = fft2(img1, 2*size(img1,1)-1, 2*size(img1,2)-1);
end
if all(size(img2) ~= size(img1))
    img2 = fft2(img2, size(img1,1), size(img1,2));
end

ABConj = img1 .* conj(img2);
d = ifft2(ABConj ./ abs(eps+ABConj), 'symmetric');

[pcorr, I] = max(d(:));
[dy, dx] = ind2sub(size(d), I);
dy = dy-1;
dx = dx-1;

if dx > abs(dx-size(d,2))
    dx = dx-size(d,2);
end

if dy > abs(dy-size(d,1))
    dy = dy-size(d,1);
end

tform = eye(3);
tform(3,1:2) = [dx,dy];
tform = affine2d(tform);


end

