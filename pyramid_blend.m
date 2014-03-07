function result = pyramid_blend(img1, img2)

    maska=(img1~=0);
    maskb=(img2~=0);
%     mask1=ones(size(img1));
%     mask1(find(img1==0))=0;
%     mask1(find(img2>0))=0;
%     mask2=imresize(mask1,.5,'nearest');
%     mask3=imresize(mask2,.5,'nearest');


%got these parameters from Wiggin
kernelWidth = 5; % default
cw = .375; % kernel centre weight, same as MATLAB func impyramid. 0.6 in the Paper
ker1d = [.25-cw/2 .25 cw .25 .25-cw/2];
kernel = kron(ker1d,ker1d');

    %make gaussian images
    g1img1=img1;
    g2img1=imresize(g1img1,.5,'nearest');
    g3img1=imresize(g2img1,.5,'nearest');
    
    %make laplacian from gaussian
    l3img1=g3img1;
    l2img1=g2img1 -imresize(l3img1,[size(g2img1,1) size(g2img1,2)],'nearest');
    l1img1=g1img1 -imresize(l2img1,[size(g1img1,1) size(g1img1,2)],'nearest');
    
    g1img2=img2;
    g2img2=imresize(g1img2,.5,'nearest');
    g3img2=imresize(g2img2,.5,'nearest');

    %make laplacian from gaussian
    l3img2=g3img2; 
    l2img2=g2img2 -imresize(l3img2,[size(g2img2,1) size(g2img2,2)],'nearest');
    l1img2=g1img2 -imresize(l2img2,[size(g1img2,1) size(g1img2,2)],'nearest');

    %combine lapacians
     L3=feather_blend(l3img1,l3img2);
     L2=feather_blend(l2img1,l2img2) + imresize(L3,[size(l2img1,1) size(l2img1,2) ],'nearest');
     L1=feather_blend(l1img1,l1img2) + imresize(L2,[size(l1img1,1) size(l1img1,2) ],'nearest');
  
     %normalize to between 0 and 1
     %set the original zero values out of image back to 0 after normalizing
     L1=mat2gray(L1);  

     L1=(maska|maskb).*L1;
     L1=maska.*L1+~maska.*img2;
     L1=maskb.*L1+~maskb.*img1;

     result=L1;
end