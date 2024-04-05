function [tform, inlierIndex, status] ...
    = estimateGeometricTransform2D_costumized(matchedPoints1, matchedPoints2, ...
    transformType, varargin)
% estimateGeometricTransform2D Estimate 2-D geometric transformation from matching point pairs
%   tform = estimateGeometricTransform2D(matchedPoints1, matchedPoints2,...
%   transformType) returns a 2-D geometric transformation which maps the
%   inliers in matchedPoints1 to the inliers in matchedPoints2.
%   matchedPoints1 and matchedPoints2 can be M-by-2 matrices of [x,y]
%   coordinates or objects of any of the <a href="matlab:helpview(fullfile(docroot,'toolbox','vision','vision.map'),'pointfeaturetypes')">point feature types</a>. transformType
%   can be 'rigid', 'similarity', 'affine' or 'projective'. Returned tform
%   types are as follows:
%
%   -------------------------------------
%   transformType    |  tform object
%   -----------------|-------------------
%   rigid            |  rigid2d
%   similarity       |  affine2d
%   affine           |  affine2d
%   projective       |  projective2d
%   -------------------------------------
%
%   [tform, inlierIndex] = estimateGeometricTransform2D(...) additionally
%   returns inlierIndex, an M-by-1 logical vector containing 1 for inliers
%   and 0 for outliers. M is the total number of 2-D point pairs.
%
%   [tform, inlierIndex, status] = estimateGeometricTransform2D(...)
%   additionally returns a status code with the following possible values:
%
%   0: No error.
%   1: matchedPoints1 and matchedPoints2 do not contain enough points.
%   2: Not enough inliers have been found.
%
%   When the status output is not requested, the function will throw an
%   error if matchedPoints1 and matchedPoints2 do not contain enough points
%   or if not enough inliers have been found.
%
%   [...] = estimateGeometricTransform2D(matchedPoints1, matchedPoints2,...
%   transformType, Name, Value) specifies additional name-value pair
%   arguments described below:
%
%   'MaxNumTrials'        A positive integer scalar specifying the maximum
%                         number of random trials for finding the inliers.
%                         Increasing this value will improve the robustness
%                         of the output at the expense of additional
%                         computation.
%
%                         Default: 1000
%
%   'Confidence'          A numeric scalar, C, 0 < C < 100, specifying the
%                         desired confidence (in percentage) for finding
%                         the maximum number of inliers. Increasing this
%                         value will improve the robustness of the output
%                         at the expense of additional computation.
%
%                         Default: 99
%
%   'MaxDistance'         A positive numeric scalar specifying the maximum
%                         distance that a point can differ from the
%                         projected location of its associated point to be
%                         considered an inlier.
%
%                         Default: 1.5
%
%   Notes
%   -----
%   Outliers in matchedPoints1 and matchedPoints2 are excluded by using the
%   M-estimator SAmple Consensus (MSAC) algorithm. The MSAC algorithm is a
%   variant of the Random Sample Consensus (RANSAC) algorithm.
%
%   Class Support
%   -------------
%   matchedPoints1 and matchedPoints2 can be numeric, or any of the
%   <a href="matlab:helpview(fullfile(docroot,'toolbox','vision','vision.map'),'pointfeaturetypes')">point feature types</a>.
%
%
%   EXAMPLE: Recover a transformed image using SURF feature points
%   --------------------------------------------------------------
%   original = imread('cameraman.tif');
%   imshow(original)
%   title('Original image')
%
%   % Transformation with a 30 degree rotation and scaled by a factor of 0.7
%   theta = 30;
%   scale = 0.7;
%   tform = affine2d([scale*cosd(theta)    sind(theta)      0; ...
%                       -sind(theta)    scale*cosd(theta)   0; ...
%                            0                 0            1]);
%
%   distorted = imwarp(original, tform);
%   figure
%   imshow(distorted)
%   title('Transformed image')
%
%   % Detect features from both images
%   ptsOriginal  = detectSURFFeatures(original);
%   ptsDistorted = detectSURFFeatures(distorted);
%
%   % Extract features from both images
%   [featuresOriginal, validPtsOriginal]   = extractFeatures(original,...
%       ptsOriginal);
%   [featuresDistorted, validPtsDistorted] = extractFeatures(distorted,...
%       ptsDistorted);
%
%   % Match feature vectors
%   indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
%   matchedPtsOriginal  = validPtsOriginal(indexPairs(:,1));
%   matchedPtsDistorted = validPtsDistorted(indexPairs(:,2));
%
%   figure
%   showMatchedFeatures(original, distorted, matchedPtsOriginal,...
%       matchedPtsDistorted);
%   title('Matched SURF points including outliers')
%
%   % Exclude the outliers and compute the transformation matrix
%   [tformEst, inlierIndex] = estimateGeometricTransform2D(...
%       matchedPtsDistorted, matchedPtsOriginal, 'affine');
%
%   figure
%   showMatchedFeatures(original, distorted,...
%       matchedPtsOriginal(inlierIndex), matchedPtsDistorted(inlierIndex));
%   title('Matched inlier points')
%
%   % Recover the original image from the distorted image
%   outputView = imref2d(size(original));
%   recovered = imwarp(distorted, tformEst, 'OutputView', outputView);
%
%   figure
%   imshow(recovered)
%   title('Recovered image')
%
% See also estimateGeometricTransform3D, fitgeotrans, cornerPoints,
%          SURFPoints, MSERRegions, BRISKPoints, ORBPoints,
%          detectMinEigenFeatures, detectFASTFeatures, detectSURFFeatures,
%          detectMSERFeatures, detectBRISKFeatures, detectORBFeatures,
%          matchFeatures, imwarp, extractFeatures, ransac.

% Copyright 2020 The MathWorks, Inc.

% References:
% [1] R. Hartley, A. Zisserman, "Multiple View Geometry in Computer
%     Vision," Cambridge University Press, 2003.
% [2] P. H. S. Torr and A. Zisserman, "MLESAC: A New Robust Estimator
%     with Application to Estimating Image Geometry," Computer Vision
%     and Image Understanding, 2000.

%#codegen

reportError = (nargout ~= 3);
is2D = true;

[tform, inlierIndex, status] = ...
    algEstimateGeometricTransform_customized(...
    matchedPoints1, matchedPoints2, transformType, reportError,...
    'estimateGeometricTransform2D', is2D, varargin{:});

end