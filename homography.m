% Algorithm Outline
% 1. Choose one image as the reference frame.
% 2. Estimate homography between each of the remaining images and the reference image. To estimate homography between two images use the following procedure:
    % a. Detect local features in each image.
    % b. Extract feature descriptor for each feature point
    % c. Match feature descriptors between two images. 
    % d. Robustly estimate homography using RANSAC.
% 3. Warp each image into the reference frame and composite warped images into a single mosaic.

function H = homography(images,reference)

%read in images
img1 = imread(images{reference});

allH={};
minU=1;
maxU=size(img1,2);
minV=1;
maxV=size(img1,1);

%set up camera parameters
focalLength=660.8799;
k1=-0.18533;
k2=0.21517;

%caclulate the homographies for each image to the neighbor image
for i=1:length(images)
    if (i==reference)
        allH{i}=eye(3);
        continue
    end
    if i<reference
        j=i+1;
    else
        j=i-1;
    end
    img1 = imread(images{j}); 
    img2 = imread(images{i});

    
    img1 = inverse_cylinderical_projection (img1,focalLength,k1,k2);
    img2 = inverse_cylinderical_projection (img2,focalLength,k1,k2);

    im1= im2single(img1);
    im2 = im2single(img2);

    H=calcHomography(im1,im2);
    allH{i}=H;
end

%calculate the homography from each image to the reference image
for i=1:length(images)
    
    if(i==reference)
        continue
    end
    img2 = imread(images{i});
    im2 = im2single(img2);
    
temp2 = [1 size(im2,2) size(im2,2) 1 ;...
        1  1 size(im2,1) size(im2,1);...
        1 1 1 1 ] ;

    H=allH{i};
    inc=1;
    if i>reference
        inc=-1;
    end
    for ind=i+inc:inc:(reference-inc)
        H=H*allH{ind};
    end
    %transforming X2 by inv(H) to get the reconstructed scene image
    temp2_proj = inv(H) * temp2 ;

    %project each image onto the same surface 
    temp2_proj(1,:) = temp2_proj(1,:) ./ temp2_proj(3,:) ;
    temp2_proj(2,:) = temp2_proj(2,:) ./ temp2_proj(3,:) ;
    minU=min([minU,temp2_proj(1,:)]);
    maxU=max([maxU,temp2_proj(1,:)]);
    minV=min([minV,temp2_proj(2,:)]);
    maxV=max([maxV temp2_proj(2,:)]);
end

ur = minU:maxU ;
vr = minV:maxV;

[u,v] = meshgrid(ur,vr); 

%reconstructing  im1
img1 = imread(images{reference});
img1=inverse_cylinderical_projection (img1,focalLength,k1,k2);
im1=im2single(img1);
im1_reconst = vl_imwbackward(im2double(im1),u,v) ;

reconst={};

% reconstruct each image
for i=1:length(images)
    if i==reference
        reconst{i}=im1_reconst;
    end
    
    H=allH{i};
    
    inc=1;
    if i>reference
        inc=-1;
    end
    for ind=i+inc:inc:(reference-inc)
        H=H*allH{ind};
    end
    img2 = im2single(imread(images{i}));
        
    % reconstructing im2
    % (x,y,z)' = (fx/z, fy/z)
    z_proj = H(3,1) * u + H(3,2) * v + H(3,3) ;
    u_proj = (H(1,1) * u + H(1,2) * v + H(1,3)) ./ z_proj ;
    v_proj = (H(2,1) * u + H(2,2) * v + H(2,3)) ./ z_proj ;
    
    %vl_imwbackward returns the pixels of image im2 at positions u_proj and v_proj
    im2_reconst = vl_imwbackward(im2double(img2),u_proj,v_proj) ;
    reconst{i}=im2_reconst;
end
im1_reconst=reconst{1};
im1_reconst(isnan(im1_reconst)) = 0 ;
top=min(find(im1_reconst(:,end-50)>0));
slope=top/size(im2_reconst,2);

%blend all of the images together
for i=2:length(images)
    im2_reconst=reconst{i};
    im2_reconst(isnan(im2_reconst)) = 0 ;
    %use feather blending
    im1_reconst=feather_blend(im1_reconst,im2_reconst);
end


imagesc(im1_reconst) 
H=im1_reconst;
end
