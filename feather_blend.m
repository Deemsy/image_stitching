function [ mosaic ] = feather_blend( img1,img2 )
%% assumes img1 image is on the left and img2 is on the right

%%blends the middle 1/5th of the image at the moment
beginBlend=floor(size(img1,2)/5)*2;
endBlend=floor(size(img1,2)/5)*3;

mosaic=zeros(size(img1));
for channel=1:3
    img1c=img1(:,:,channel);
    img2c=img2(:,:,channel);
    
    final=zeros(size(img1c,1),size(img1c,2));
    final(:,1:beginBlend-1)=img1c(:,1:beginBlend-1);
    final(:,endBlend+1:end)=img2c(:,endBlend+1:end);
    %%does a simple linear interpolation:  (1-w)*img1 + (w)*img2
    for j=beginBlend:endBlend
        for i=1:size(img1c,1)
            final(i,j)= img1c(i,j)*(endBlend-j)/(endBlend-beginBlend) + img2c(i,j)*(j-beginBlend)/(endBlend-beginBlend); 
        end
    end
    mosaic(:,:,channel)=final;
end


end

