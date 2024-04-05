function [Y2, X2, index_ImMatch2, pointsPreviousNumb2, pointsNumb2, matchedNumb2, inlierNumb2, status] = compute_trasnform_west( I1, I2, index_matrix, M, N, X_pixel, Overlap_west, Threshold_metric)
% Detect SURF features in the right image (I1) within the specified region of interest (ROI)
pointsPrevious = detectSURFFeatures(I1, 'ROI',[1 1 X_pixel M],'MetricThreshold', Threshold_metric);
% Detect SURF features in the left image (I2) within the specified region of interest (ROI)
points = detectSURFFeatures(I2, 'ROI',[round(N*(100-Overlap_west)/100) 1 X_pixel M],'MetricThreshold', Threshold_metric);
% Extract SURF features from both images
[featuresPrevious, pointsPrevious] = extractFeatures(I1, pointsPrevious);
[features, points] = extractFeatures(I2, points);
% Count the number of detected points in each image
pointsPreviousNumb2 = length(pointsPrevious);
pointsNumb2 = length(points);
% Find correspondences between features in the two images
indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
matchedNumb2 = length(matchedPoints);

if matchedNumb2 == 0  % No matches found
    inlierNumb2 = NaN;
    index_ImMatch2 = NaN;
    matchedNumb2 = NaN;
    status = 1;
    X2 = NaN;
    Y2 = NaN;
else
    % Estimate geometric transformation between the matched points
    [tforms2,inlierIndex, status] =  estimateGeometricTransform2D_customized(matchedPointsPrev, matchedPoints,'rigid', 'Confidence', 99.99, 'MaxNumTrials', 2000);
    if status == 0 % Successful transformation estimation
        index_ImMatch2 = index_matrix;
        inlierNumb2 = sum(inlierIndex);
        X2 = (tforms2.Translation(1));
        Y2 = (tforms2.Translation(2));
    else  % Failed transformation estimation
        inlierNumb2 = NaN;
        index_ImMatch2 = NaN;
        X2 = NaN;
        Y2 = NaN;
    end

end
end