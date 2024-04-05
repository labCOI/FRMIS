function [tform, inlierIdx, status] = ...
    algEstimateGeometricTransform_customized(matchedPoints1, matchedPoints2,...
    transformType, reportError, funcName, is2D, varargin)
% Main algorithm used by estimateGeometridTransform2D,
% estimateGeometricTransform3D and estimateGeometricTransform.

% No input validation is done in this function.
% matchedPoints1   - M-by-2 matrix or M-by-3 matrix of coordinates
% matchedPoints2   - M-by-2 matrix or M-by-3 matrix of coordinates
% transformType    - 'rigid', 'similarity', 'affine' or 'projective'
% reportError      - Boolean
% funcName         -'estimateGeometricTransform',
%                   'estimateGeometricTransform2D' or
%                   'estimateGeometricTransform3D'
% is2D             - Boolean

% Copyright 2020 The MathWorks, Inc.

%#codegen

% List of status codes
statusCode = struct(...
    'NoError',           int32(0),...
    'NotEnoughPts',      int32(1),...
    'NotEnoughInliers',  int32(2));

% Parse and check inputs
[points1, points2, ransacParams, sampleSize, tformType, status, classToUse] = ...
    parseEstimateGeometricTransform_customized(statusCode,...
    matchedPoints1, matchedPoints2, transformType, funcName, is2D,...
    varargin{:});

% Return identity matrix in case of failure
if is2D
    failedMatrix = eye(3, classToUse);
else %3D
    failedMatrix = eye(4, classToUse);
end

% Compute the geometric transformation
if status == statusCode.NoError
    ransacFuncs = getRansacFunctions(tformType, is2D);
    points = cast(cat(3, points1, points2), classToUse);

    [isFound, tmatrix, inlierIdx] = vision.internal.ransac.msac(...
        points, ransacParams, ransacFuncs);

    if ~isFound
        status = statusCode.NotEnoughInliers;
    end

    % Do an extra check to verify the tform matrix. Check if matrix is
    % singular or contains infs or nans.
    if isequal(det(tmatrix),0) || any(~isfinite(tmatrix(:)))
        status = statusCode.NotEnoughInliers;
        tmatrix = failedMatrix;
    end
else
    % Need to assign a dummy value to satisfy def-before-use analysis.
    inlierIdx = false(size(matchedPoints1,1));
    tmatrix = failedMatrix;
end

if (status ~= statusCode.NoError)
    tmatrix = failedMatrix;
end

% Report runtime error if the status output is not requested
if reportError
    checkRuntimeStatus(statusCode, status, sampleSize);
end

if is2D
    if isequal(tformType,'r')
        tform = rigid2d(tmatrix(1:3,1:3));
    elseif isequal(tformType,'p')
        tform = projective2d(tmatrix(1:3,1:3));
    else % Similarity and affine
        % Use the 3x2 affine2d syntax to have last column automatically
        % added to tform matrix. This prevents precision issues from
        % propagating downstream.
        tform = affine2d(tmatrix(:,1:2));
    end
else % 3D
    if (isequal(tformType,'r'))
        tform = rigid3d(tmatrix);
    else % 's'
        tform = affine3d(tmatrix);
    end
end
end

%==========================================================================
% Check runtime status and report error if there is one
%==========================================================================
function checkRuntimeStatus(statusCode, status, sampleSize)

if (status == statusCode.NotEnoughPts)
    coder.internal.error('vision:points:notEnoughMatchedPts',...
        'matchedPoints1', 'matchedPoints2', sampleSize);
elseif (status == statusCode.NotEnoughInliers)
    coder.internal.error('vision:points:notEnoughInlierMatches',...
        'matchedPoints1', 'matchedPoints2');
end

end

%==========================================================================
function ransacFuncs = getRansacFunctions(tformType, is2D)
ransacFuncs.checkFunc = @checkTForm;

if is2D
    ransacFuncs.evalFunc = @evaluateTform2d;
    switch(tformType)
        case 'r'
            ransacFuncs.fitFunc = @computeRigid2d;
        case 's'
            ransacFuncs.fitFunc = @computeSimilarity2d;
        case 'a'
            ransacFuncs.fitFunc = @computeAffine2d;
        otherwise % 'p'
            ransacFuncs.fitFunc = @computeProjective2d;
    end
else % 3D
    ransacFuncs.evalFunc = @evaluateTform3d;
    switch(tformType)
        case 'r'
            ransacFuncs.fitFunc = @computeRigid3d;
        otherwise % 's'
            ransacFuncs.fitFunc = @computeSimilarity3d;
    end
end
end

%==========================================================================
% Algorithms for computing the transformation matrix.
%==========================================================================
function T = computeRigid2d(points)

points1 = points(:,:,1);
points2 = points(:,:,2);

[R, t] = computeRigidTransform_customized(points1, points2);
T = coder.nullcopy(eye(3, 'like', points));
T(:,1:2) = [R'; t];

end

%==========================================================================
function T = computeSimilarity2d(points)
classToUse = class(points);

[points1, points2, normMatrix1, normMatrix2] = ...
    normalizePoints(points, classToUse);

numPts = size(points1, 1);
constraints = zeros(2*numPts, 5, 'like', points);
constraints(1:2:2*numPts, :) = [-points1(:, 2), points1(:, 1), ...
    zeros(numPts, 1), -ones(numPts,1), points2(:,2)];
constraints(2:2:2*numPts, :) = [points1, ones(numPts,1), ...
    zeros(numPts, 1), -points2(:,1)];

[~, ~, V] = svd(constraints, 0);
h = V(:, end);
T = coder.nullcopy(eye(3, 'like', points));
T(:, 1:2) = [h(1:3), [-h(2); h(1); h(4)]] / h(5);
T(:, 3)   = [0; 0; 1];

T = denormalizeTform(T, normMatrix1, normMatrix2);

end

%==========================================================================
function T = computeAffine2d(points)
classToUse = class(points);

[points1, points2, normMatrix1, normMatrix2] = ...
    normalizePoints(points, classToUse);

numPts = size(points1, 1);
constraints = zeros(2*numPts, 7, 'like', points);
constraints(1:2:2*numPts, :) = [zeros(numPts, 3), -points1, ...
    -ones(numPts,1), points2(:,2)];
constraints(2:2:2*numPts, :) = [points1, ones(numPts,1), ...
    zeros(numPts, 3), -points2(:,1)];

[~, ~, V] = svd(constraints, 0);
h = V(:, end);
T = coder.nullcopy(eye(3, 'like', points));
T(:, 1:2) = reshape(h(1:6), [3,2]) / h(7);
T(:, 3)   = [0; 0; 1];

T = denormalizeTform(T, normMatrix1, normMatrix2);

end

%==========================================================================
function T = computeProjective2d(points)
classToUse = class(points);

[points1, points2, normMatrix1, normMatrix2] = ...
    normalizePoints(points, classToUse);

numPts = size(points1, 1);
p1x = points1(:, 1);
p1y = points1(:, 2);
p2x = points2(:, 1);
p2y = points2(:, 2);
constraints = zeros(2*numPts, 9, 'like', points);
constraints(1:2:2*numPts, :) = [zeros(numPts,3), -points1, ...
    -ones(numPts,1), p1x.*p2y, p1y.*p2y, p2y];
constraints(2:2:2*numPts, :) = [points1, ones(numPts,1), ...
    zeros(numPts,3), -p1x.*p2x, -p1y.*p2x, -p2x];

[~, ~, V] = svd(constraints, 0);
h = V(:, end);
T = reshape(h, [3,3]) / h(9);

T = denormalizeTform(T, normMatrix1, normMatrix2);

end

%==========================================================================
function T = computeRigid3d(points)

points1 = points(:,:,1);
points2 = points(:,:,2);

% Get transform
[R,t] = vision.internal.calibration.computeRigidTransform(points1,points2);
T = coder.nullcopy(eye(4, 'like', points));
T(:,1:3) = [R'; t'];
T(:,4)   = [0; 0; 0; 1];

end

%==========================================================================
function T = computeSimilarity3d(points)
classToUse = class(points);

[points1, points2, normMatrix1, normMatrix2] = ...
    normalizePoints(points, classToUse);

% Get transform
T = vision.internal.computeSimilarityTransform3D(points1,points2)';
T = denormalizeTform(T, normMatrix1, normMatrix2);

end

%==========================================================================
function [samples1, samples2, normMatrix1, normMatrix2] = ...
    normalizePoints(points, classToUse)
points1 = cast(points(:,:,1), classToUse);
points2 = cast(points(:,:,2), classToUse);

if (size(points1,2) == 2) % 2D
    [samples1, normMatrix1] = ...
        vision.internal.normalizePoints(points1', 2, classToUse);
    [samples2, normMatrix2] = ...
        vision.internal.normalizePoints(points2', 2, classToUse);
else % 3D
    [samples1, normMatrix1] = ...
        vision.internal.normalizePoints(points1', 3, classToUse);
    [samples2, normMatrix2] = ...
        vision.internal.normalizePoints(points2', 3, classToUse);
end

samples1 = samples1';
samples2 = samples2';
end

%==========================================================================
function tform = denormalizeTform(tform, normMatrix1, normMatrix2)
tform = normMatrix1' * (tform / normMatrix2');
tform = tform ./ tform(end);
end

%==========================================================================
function dis = evaluateTform2d(tform, points)
points1 = points(:, :, 1);
points2 = points(:, :, 2);

numPoints = size(points1, 1);
pt1h = [points1, ones(numPoints, 1, 'like', points)];
pt1h = pt1h * tform;
w = pt1h(:, 3);
pt = pt1h(:,1:2) ./ [w, w];
delta = pt - points2;
dis   = hypot(delta(:,1),delta(:,2));
dis(abs(pt1h(:,3)) < eps(class(points))) = inf;
end

%==========================================================================
function dis = evaluateTform3d(tform, points)
points1 = points(:, :, 1);
points2 = points(:, :, 2);

numPoints = size(points1, 1);
pt1h = [points1, ones(numPoints, 1, 'like', points)];

tpoints1 = pt1h * tform;

dis = sqrt((tpoints1(:,1) - points2(:,1)).^2 +...
    (tpoints1(:,2) - points2(:,2)).^2 +...
    (tpoints1(:,3) - points2(:,3)).^2);
end

%==========================================================================
function tf = checkTForm(tform)
tf = all(isfinite(tform(:)));
end
