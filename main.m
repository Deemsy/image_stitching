addpath ../../vlfeat/vlfeat-0.9.18/toolbox
vl_setup
directory='../powerplant/';
images=load_images(directory);
img=homography(images(1:3),2);
imagesc(img);
imwrite(img,'panorama1.jpg');