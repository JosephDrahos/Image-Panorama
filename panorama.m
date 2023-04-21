clear;clc;close all;

%uncomment which set of images you want to create the pano for
im1 = imread('Image1.jpg');
im2 = imread('Image2.jpg');
im1 = imread('IMG_8232.jpg');
im2 = imread('IMG_8233.jpg');

im1 = rgb2gray(im2double(im1));
im2 = rgb2gray(im2double(im2));
figure(1)
imshow(im1)
figure(2)
imshow(im2)

%% Correspondence

points1 = detectSURFFeatures(im1);
features1 = extractFeatures(im1,points1);


points2 = detectSURFFeatures(im2);
features2 = extractFeatures(im1,points2);

indexPairs = matchFeatures(features1, features2, 'Unique', true);

matchedPoints1 = points1(indexPairs(:,1));
matchedPoints2 = points2(indexPairs(:,2));

im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

figure(3)
showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2);


%% Estimating Homography
%loop until favorable ransac output, usually stop once i see one thatll
%work
for test = 1:10
    homography = estimateTransformRANSAC(im1_points,im2_points);
    homography = inv(homography);
    homography = homography ./ homography(3,3)
    
    im2_transform = imageTransform(im2,homography,'homography');
    
    %transformed image never translates without this
    newHom = [1,0;0,1;0,0];
    newHom = [newHom, abs(homography(:,3))];
    
    im2_transform = imageTransform(im2_transform,newHom,'homography');
        
    figure(4)
    imshow(im2_transform)

end



%% expanding image

[h,w] = size(im1);
[h2,w2] = size(im2_transform);

im1_expanded = zeros(h2,w2);
im1_expanded(1:h,1:w) = im1;

figure(6)
imshow(im1_expanded)
[x_overlap,y_overlap] = ginput(2);


%% blending image

overlapleft = round(x_overlap(1));
overlapright = round(x_overlap(2));

zeros_till_overlapleft = zeros(1,overlapleft-1);
stepvalue = 1/(overlapright-overlapleft);
ones_till_overlapright = ones(1,w2-overlapright);
r = [0 : stepvalue : 1];
ramp=[zeros_till_overlapleft, r , ones_till_overlapright];

figure(7)
plot(ramp)

im2_blend = im2double(im2_transform) .* repmat(ramp,h2,1);

im1ramp = abs(ramp-1);

im1_blend = im2double(im1_expanded) .* repmat(im1ramp,h2,1);

figure(8)
imshow(im2_blend)
figure(9)
imshow(im1_blend)

impanorama = im1_blend+im2_blend;

figure(10)
imshow(impanorama)

%% save images

imwrite(im2_transform, 'im2_transformed.png')
imwrite(im1_expanded, 'im1_expanded.png')
imwrite(im1_blend, 'im1_blend.png')
imwrite(im2_blend, 'im2_blend.png')
imwrite(impanorama, 'impanorama.png')