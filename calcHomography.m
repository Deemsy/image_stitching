function H=calcHomography(im1,im2)

if size(im1,3) > 1, I1 = rgb2gray(im1) ; else I1 = im1 ; end
if size(im2,3) > 1, I2 = rgb2gray(im2) ; else I2 = im2 ; end

% get SIFT features
[f1,d1] = vl_sift(I1) ;
[f2,d2] = vl_sift(I2) ;

% To Steve: we can play with the third parameter, it's 1.5 by default 
[matches, scores] = vl_ubcmatch(d1,d2) ;

num_matches = size(matches,2) ;

% f1 and f2 both have a column for each keypoint. 
% From the documentation: A keypoint is a disk of center f1(1:2), scale f(3) and orientation f(4)
X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;


% nDLT using SVD to solve the least square problem that
%Ransac depends on. Source: http://vision.ece.ucsb.edu/~zuliani/Research/RANSAC/docs/RANSAC4Dummies.pdf

% We repeat 100 times to ensure robustness and then we take the best
% solution
for j = 1:100
  
  %vl_colsubset(x,n) returns a random subset y of n columns of x. It's order preserving and without replacement 
  rand_cols = vl_colsubset(1:num_matches, 4) ;
  A = [] ;
  
  % kron() is the Kronecker Tensor Product of two matrices A and B. The
  % resulting matrix is formed by multiplying B by every element in A.
  % function details: http://www.mathworks.com/help/matlab/ref/kron.html#bt0autl-2_1
  % vl_hat returns a skew symmetric matrix
  % cat concatenates arrays along the dimension specified in the first
  % parameter
  for i = rand_cols
    A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
  end
  
  % Singular Value Decomposition
  % The solution to the linear system (DLT) is the eigenvector associated
  % with the smallest eigenvalue. 
  %[U,S,V] = svd(A); X = V(:,end) source: http://www.cs.unc.edu/~lazebnik/spring09/assignment3.html
  [U,S,V] = svd(A) ;
  H{j} = reshape(V(:,9),3,3) ;

  % Measuring the quality of this solution by computing the distance 
  %between corresponding points AFTER applying the transformation
  
  X1_proj = H{j} * X1 ; 
  deltaU = X1_proj(1,:)./X1_proj(3,:) - X2(1,:)./X2(3,:) ;
  deltaV = X1_proj(2,:)./X1_proj(3,:) - X2(2,:)./X2(3,:) ;
  
  %the next instruction should first calculate the paranethesis then it
  %compares the values to 36. If the value <36, the value in ok will be one
  %(TRUE). otherwise it'll be 0 (False)
  temp{j} = (deltaU.*deltaU + deltaV.*deltaV) < 6 ;
  score(j) = sum(temp{j}) ;
end

[~, best] = max(score) ;
H = H{best} ;