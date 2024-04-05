function [Y1, X1, index_ImMatch1, pointsPreviousNumb1, pointsNumb1, matchedNumb1, inlierNumb1, status] = compute_trasnform_north(I1, I2, index_matrix, M, N, Y_pixel, Overlap_north, Threshold_metric)

% Detect SURF features in the down image (I1) within the specified region of interest (ROI)
pointsPrevious = detectSURFFeatures(I1, 'ROI',[1 1 N Y_pixel],'MetricThreshold', Threshold_metric);
% Detect SURF features in the  up image (I2) within the specified region of interest (ROI)
points = detectSURFFeatures(I2,'ROI',[1 round(M*(100-Overlap_north)/100) N Y_pixel],'MetricThreshold', Threshold_metric);
% Extract SURF features from both images
[featuresPrevious, pointsPrevious] = extractFeatures(I1, pointsPrevious);
[features, points] = extractFeatures(I2, points);
% Count the number of detected points in each image
pointsPreviousNumb1 = length(pointsPrevious);
pointsNumb1 = length(points);
% Find correspondences between features in the two images
indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
matchedPoints = points(indexPairs(:,1), :);
matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
matchedNumb1 = length(matchedPoints);

if matchedNumb1 == 0       % No matches found
    inlierNumb1 = NaN;
    index_ImMatch1 = NaN;
    matchedNumb1 = NaN;
    status = 1;
    X1 = NaN;
    Y1 = NaN;

else
    % Estimate geometric transformation between the matched points
    [tforms1,inlierIndex, status] =  estimateGeometricTransform2D_customized(matchedPointsPrev, matchedPoints,'rigid', 'Confidence', 99.99, 'MaxNumTrials', 2000);

    if status == 0 % Successful transformation estimation
        index_ImMatch1 = index_matrix;
        inlierNumb1 = sum(inlierIndex);
        X1 = (tforms1.Translation(1));
        Y1 = (tforms1.Translation(2));
    else  % Failed transformation estimation
        inlierNumb1 = NaN;
        index_ImMatch1 = NaN;
        X1 = NaN;
        Y1 = NaN;
    end
end
end