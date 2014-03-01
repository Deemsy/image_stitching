function result = pyramid_blend(img1, img2)
%% assumes img1 image is on the left and img2 is on the right

    %make gaussian images
    g1img1=img1;
    g2img1=imresize(g1img1,.5,'nearest');
    g3img1=imresize(g2img1,.5,'nearest');
    
    %make laplacian from gaussian
    l3img1=g3img1;
    l2img1=g2img1 - imresize(l3img1,2,'nearest');
    l1img1=g1img1 - imresize(l2img1,2,'nearest');
    
    g1img2=img2;
    g2img2=imresize(g1img2,.5,'nearest');
    g3img2=imresize(g2img2,.5,'nearest');
    %make laplacian from gaussian
    l3img2=g3img2;   
    l2img2=g2img2 - imresize(l3img2,2,'nearest');
    l1img2=g1img2 - imresize(l2img2,2,'nearest');
    
    %combine lapacians
     L3=feather_blend(l3img1,l3img2);
     L2=feather_blend(l2img1,l2img2) + imresize(L3,2);
     L1=feather_blend(l1img1,l1img2) + imresize(L2,2);

     %normalize to between 0 and 1
     L1(:,:,1)=mat2gray(L1(:,:,1));
     L1(:,:,2)=mat2gray(L1(:,:,2));
     L1(:,:,3)=mat2gray(L1(:,:,3));
     
end