%change this to location of vlfeat toolbox
addpath ../../vlfeat/vlfeat-0.9.18/toolbox
vl_setup
directory='powerplant';
images=load_images(directory);

%homography does the projections and blending
%parameters are the list of filenames and the reference image
img=homography(images,4);

imwrite(img,'panorama1.jpg');