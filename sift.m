%http://www.vlfeat.org/overview/sift.html

function [d1,d2,matches,scores] = sift(im1, im2)

%reading images here for testing. should move to main 

I1 = single(rgb2gray(im2double(imread(im1))));
I2 =  single(rgb2gray(im2double(imread(im2))));

[f1, d1] = vl_sift(I1);
[f2, d2] = vl_sift(I2);

size(f1), size(d1)
size(f2), size(d2)

[matches, scores] = vl_ubcmatch(d1, d2, 5);

size(matches), size(scores)
%subplot(1,2,1);
%imshow(I1);
%hold on;
%plot(f1(1,matches(1,:)), f1(2, matches(1,:)), 'b*');

%subplot(1,2,2);
%imshow(I2);
%hold on;
%plot(f2(1,matches(2,:)), f2(2, matches(2,:)), 'r*');
end