%imageTransform function
%inputs: InputImage - RGB Image
%        TransformMatrix - 3x3 Transformation Matrix to be applied to image
%        TransformType - String describing transformation matrix 
%        examples: ‘scaling’, ‘rotation’, ‘translation’, ‘reflection’, ‘shear’, ‘affine’, ‘homography’
%
%outputs: Transformed RGB Image
function Iprime = imageTransform(InputImage, TransformMatrix, TransformType)
    % inputImage I
    % TransformMatrix A: 3x3
    % I needs to be obtained, A needs to obtained, invA needs to be obtained
    
    [H,W,channels] = size(InputImage);
    InputImage = im2double(InputImage);

    c1 = [1,1,1]';
    c2 = [W,1,1]';
    c3 = [1,H,1]';
    c4 = [W,H,1]';
    
    cp1 = TransformMatrix*c1;
    cp2 = TransformMatrix*c2;
    cp3 = TransformMatrix*c3;
    cp4 = TransformMatrix*c4;

    %inverse scaled by w (im not sure of a better solution other than
    %normalizing the transformation matrix by the (3,3) value
    xp1 = cp1(1)/cp1(3); yp1 = cp1(2)/cp1(3);
    xp2 = cp2(1)/cp2(3); yp2 = cp2(2)/cp2(3);
    xp3 = cp3(1)/cp3(3); yp3 = cp3(2)/cp3(3);
    xp4 = cp4(1)/cp4(3); yp4 = cp4(2)/cp4(3);



    Ap = [min( [1,xp1,xp2,xp3,xp4] ), min( [1,yp1,yp2,yp3,yp4] )];
    Bp = [min( [1,xp1,xp2,xp3,xp4] ), max( [yp1,yp2,yp3,yp4] )];
    Cp = [max( [xp1,xp2,xp3,xp4] ), min( [1,yp1,yp2,yp3,yp4] )];
    Dp = [max( [xp1,xp2,xp3,xp4] ), max( [yp1,yp2,yp3,yp4] )];

    minx = Ap(1); miny = Ap(2);
    maxx = Cp(1); maxy = Dp(2);
    
    [Xprime,Yprime] = meshgrid( minx:maxx, miny:maxy );

    heightIprime = height(Xprime);
    widthIprime = width(Yprime);
    
    %different inverse calculation depending on transform type
    if strcmp(TransformType,'scaling')
        sx = TransformMatrix(1,1);
        sy = TransformMatrix(2,2);

        invMatrix = TransformMatrix;
        invMatrix(1,1) = 1/sx;
        invMatrix(2,2) = 1/sy;
    elseif strcmp(TransformType,'rotation')
        invMatrix = TransformMatrix';
    elseif strcmp(TransformType,'translation')
        tx = TransformMatrix(1,3);
        ty = TransformMatrix(2,3);
        invMatrix = TransformMatrix;
        invMatrix(1,3) = -tx;
        invMatrix(2,3) = -ty;
    elseif strcmp(TransformType,'reflection')
        invMatrix = TransformMatrix;
    elseif strcmp(TransformType,'shear')
        rx = TransformMatrix(1,2);
        ry = TransformMatrix(2,1);
        invMatrix = TransformMatrix;
        invMatrix(1,2) = -rx;
        invMatrix(2,1) = -ry;
    else
        invMatrix = inv(TransformMatrix);
    end

    pprimematrix = [Xprime(:)';Yprime(:)';ones(1,heightIprime*widthIprime)];
    phatmatrix = invMatrix * pprimematrix;

    xlongvector = phatmatrix(1,:) ./ phatmatrix(3,:);
    ylongvector = phatmatrix(2,:) ./ phatmatrix(3,:);
    
    xmatrix = reshape( xlongvector', heightIprime, widthIprime );
    ymatrix = reshape( ylongvector', heightIprime, widthIprime );
    
    %interpolates each color channel and then combines back into output rhb
    %matrix
    if channels == 3
        Iprimer = interp2(InputImage(:,:,1),xmatrix,ymatrix );
        Iprimeg = interp2(InputImage(:,:,2),xmatrix,ymatrix );
        Iprimeb = interp2(InputImage(:,:,3),xmatrix,ymatrix );

        Iprime = ones(heightIprime, widthIprime, channels);
        Iprime(:,:,1) = Iprimer;
        Iprime(:,:,2) = Iprimeg;
        Iprime(:,:,3) = Iprimeb;
        
    else
        Iprime = interp2(InputImage(:,:),xmatrix,ymatrix );
    end
    
    Iprime = im2uint8(Iprime);
end