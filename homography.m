function H = homography(images,reference)

img1 = imread(images{reference});

%images=images([1:reference-1,reference+1:end]);
%reading the images here for easy debugging. Should move them to main
allH={};
minU=1;
maxU=size(img1,2);
minV=1;
maxV=size(img1,1);
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

    img1 = inverse_cylinderical_projection (img1,595,-0.15,0);
    img2 = inverse_cylinderical_projection (img2,595,-0.15,0);

    im1= im2single(img1);
    im2 = im2single(img2);

    H=calcHomography(im1,im2);
    allH{i}=H;
end

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

    %project each image onto the same surface then blend them together
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
img1=inverse_cylinderical_projection (img1,595,-0.15,0);
im1=im2single(img1);
im1_reconst = vl_imwbackward(im2double(im1),u,v) ;

reconst={};
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
for i=2:length(images)
    im2_reconst=reconst{i};
    im2_reconst(isnan(im2_reconst)) = 0 ;
    im1_reconst=pyramid_blend(im1_reconst,im2_reconst);
end
%T=[1 -slope; 0 1 ; 0 0 ];
%t_proj=maketform('affine',T);
%im1_reconst=mat2gray(imtransform(im1_reconst,t_proj,'FillValues',.3));

imagesc(im1_reconst)
%mos=feather_blend(im1,im2);
%mosaic=pyramid_blend(im1_reconst,im2_reconst);

% mass = ~isnan(im1_reconst) + ~isnan(im2_reconst) ;
% im1_reconst(isnan(im1_reconst)) = 0 ;
% im2_reconst(isnan(im2_reconst)) = 0 ;
% mosaic = (im1_reconst + im2_reconst) ./ mass ;

%imagesc(mosaic) ; 
H=im1_reconst;
end
