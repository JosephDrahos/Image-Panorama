
function A = estimateTransform(im1_points, im2_points)
    [h,width] = size(im1_points);
    index = 1;
    p = [];
    
    for i = 1:h
        x = im1_points(i,1);
        y = im1_points(i,2);
        w = 1;
        x_t = im2_points(i,1);
        y_t = im2_points(i,2);
        w_t = 1;
    
        
        
        %eq1 = [-x,-y,-w,0,0,0,x_t*x, x_t*y,x_t*w];%[0, 0, 0, -w_t*x, -w_t*y, -w_t*w, y_t*x, y_t*y, y_t*w];%
        %p(index,:) = eq1;
        %index = index + 1;
        %eq2 = [0,0,0,-x,-y,-w,y_t*x,y_t*y,y_t*w];%[w_t*x, w_t*y, w_t*w, 0, 0, 0, -x_t*x, -x_t*y, -x_t*w];%
        %p(index,:) = eq2;
        %index = index + 1;
        eq = [-x,-y,-w,0,0,0,x_t*x, x_t*y,x_t*w;
               0,0,0,-x,-y,-w,y_t*x,y_t*y,y_t*w];
        p = [p;eq];
    end
    

    if h*2 < 9
        [U,S,V] = svd(p);
    else
        [U,S,V] = svd(p,'econ');
    end
    q = V(:,end);
    %q = q/q(end);
  
    A = reshape(q,3,3)';
end