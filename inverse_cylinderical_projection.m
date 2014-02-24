% Warping the ims into cylindrical coordinates
% equations for warping are at: http://pages.cs.wisc.edu/~dyer/cs534/hw/hw4/cylindrical.pdf
% k1, k2 are the radial distortion parameters
% equation for radial distortion is at :http://robots.stanford.edu/cs223b05/MSR-TR-2004-92-Jan26.pdf


function im_transformed = inverse_cylinderical_projection(im, f, k1, k2)

%get height and width of image
width = size(im,2); %for some reason [y,x] = size(im) is returning a wrong value for x even though the image passed has the correct dimensions!
height = size(im,1);

xc = (width+1) / 2;
yc = (height+1) / 2;

% calculate the corresponding cylindrical coordinates for every pixel in
% the source image
% note to self: should vectorize to decrease performance time
for y=1:height
    for x=1:width
        theta = (x - xc)/f;
        h = (y - yc)/f;
       
        x_hat = sin(theta);
        y_hat = h;
        z_hat = cos(theta);
        
        xn = x_hat / z_hat;
        yn = y_hat / z_hat;
        r = xn^2 + yn^2;
        
        %lens distortion using low-order polynomials
        xd = xn * (1 + k1 * r + k2 * r^2);
        yd = yn * (1 + k1 * r + k2 * r^2);
        
        ximg = floor(f * xd + xc);
        yimg = floor(f * yd + yc);
        
        if (ximg > 0 && ximg <= width && yimg > 0 && yimg <= height)
            im_transformed(y, x, :) = [im(yimg, ximg, 1) im(yimg, ximg, 2) im(yimg, ximg, 3)];
        end
                               
    end
end