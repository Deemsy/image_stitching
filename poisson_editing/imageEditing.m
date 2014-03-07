%


offsetRow=60;
offsetCol=40;
%read in source image and mask, target image
target_img=imread('balloon.jpg');
source_img=imread('deema.jpg');
mask_img=imread('deemaMask.jpg');

mask=rgb2gray(mask_img);
mask(find(mask<100))=0;
[rows cols ~]=size(source_img);
n=rows*cols;

orig_target=target_img;
%only use the portion of the target image we are inserting into
target_img=target_img((offsetRow+1):(rows+offsetRow),(offsetCol+1):(cols+offsetCol),:);

%initialize image we are solving for
finalImage=zeros(rows,cols,3);

%set up laplacian
%credit for laplacian code is from YIJIA XU @ Shanghai University of Engineering Science
%https://code.google.com/p/imageblending/
L= [0 1 0;1 -4 1; 0 1 0];



%solve each color channel
for channel=1:3
    
    target=target_img(:,:,channel);
    source=source_img(:,:,channel);
    laplacian=conv2(source,-L,'same');
    A=sparse(n,n);
    for i=1:n
        A(i,i)=1;
    end
    b=zeros(n,1);
    disp('allocated matrix')
    for i=1:rows
        for j=1:cols
            pixel=(i-1)*cols+j;
            
            if mask(i,j)==0
                b(pixel)=target(i,j);
                continue
            end 
            N=4;
            solution=0;
            for neighborRow=i-1:2:i+1
                if neighborRow<1||neighborRow>rows
                    N=N-1;
                    continue
                end

                if mask(neighborRow,j)>0
                    A(pixel,(neighborRow-1)*cols+j)=-1;
                else
                    solution=solution+target(neighborRow,j);
                end
            end
            for neighborCol=j-1:2:j+1
                if neighborCol<1||neighborCol>cols
                    N=N-1;
                    continue
                end

                if mask(i,neighborCol)>0
                    A(pixel,(i-1)*cols+neighborCol)=-1;
                else
                    solution=solution+target(i,neighborCol);
                end
            end
            solution;
            A(pixel,pixel)=N;
            b(pixel)=solution+laplacian(i,j);
        end
    end
    x=A\b;
    index=1;
    for i=1:rows
        for j=1:cols
            finalImage(i,j,channel)=x(index);
            index=index+1;
        end
    end   

end

%use full target image
orig_target((offsetRow+1):(rows+offsetRow),(offsetCol+1):(cols+offsetCol),:)=finalImage;
                
                
                
                
            