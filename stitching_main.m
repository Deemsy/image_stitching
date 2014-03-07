%main function
% Algorithm Outline
% 1. Choose one image as the reference frame.
% 2. Estimate homography between each of the remaining images and the reference image. To estimate homography between two images use the following procedure:
    % a. Detect local features in each image.
    % b. Extract feature descriptor for each feature point
    % c. Match feature descriptors between two images. 
    % d. Robustly estimate homography using RANSAC.
% 3. Warp each image into the reference frame and composite warped images into a single mosaic.


%load images
images = load_images('/u/a/l/alshamaa/Downloads/Image_Stitching/testingImages');

% choose reference image
%ref_image_index = floor((size(images,1)+1)/2);

for i=1:size(images) -1
    %if(i~=ref_image_index)
  %    H{i}= homography(imread(images{ref_image_index}), imread(images{i}));
   H{i}= homography(imread(images{i}), imread(images{i+1}));
  % end
end
%Im2w = warp(imread(images{3}),eye(3),imread(images{3}) ); % warp image 1 to mosaic %image
imm =  warp(imread(images{2}),H{1},imread(images{1}));
h__ =  homography(imm, imread(images{3}));

imm2 =  warp(imread(images{3}),h__,imm);
h2 = homography(imm2, imread(images{4}));

imm3 =  warp(imread(images{4}),h2,imm2);
h3 = homography(imm3, imread(images{5}));

imm4 = warp(imread(images{5}), h3, imm3);



%for i=1:size(warped) 
%    mosaic = mosaic + warped{i};
%end
%figure;
%hold on;
%mosaic = mosaic ./ 255;%
%imagesc(mosaic); 
