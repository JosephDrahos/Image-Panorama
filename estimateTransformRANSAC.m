function Hbetter = estimateTransformRANSAC(pts1, pts2)
    Nransac = 20000;
    th = 7;

    n = size(pts1,1);
    nkeepmax = 0;
    for ir = 1:Nransac
        idx = randperm(n,4);
        pts1s = pts1(idx,:);
        pts2s = pts2(idx,:);
        H = estimateTransform(pts1s,pts2s);

        
        pts2estim_h = H * [pts1';ones(1,n)];
        pts2estm = pts2estim_h(1:2,:) ./ pts2estim_h(3,:);
        
        pts2estim = pts2estm';
        
        d = sum((pts2estim - pts2).^2,2);
        
        keep = find( d < th );
        nkeep = length(keep);
        
        if nkeep > nkeepmax
            nkeepmax = nkeep;
            Hkeepmax = H;
            keepmax = keep;
        end
    end
    
    pts1keep = pts1(keepmax,:);
    pts2keep = pts2(keepmax,:);
    
    Hbetter = estimateTransform(pts1keep,pts2keep);
end