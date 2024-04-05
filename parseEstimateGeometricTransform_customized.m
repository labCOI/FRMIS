function [points1, points2, ransacParams, sampleSize, tformType,...
    status, classToUse] = parseEstimateGeometricTransform_customized(statusCode, ...
    matchedPoints1, matchedPoints2, transformType, fileName, is2D,...
    varargin)
%

% Copyright 2020 The MathWorks, Inc.

%#codegen

isSimulationMode = isempty(coder.target);
if isSimulationMode
    % Instantiate an input parser
    parser = inputParser;
    parser.FunctionName = fileName;

    % Specify the optional parameters
    parser.addParameter('MaxNumTrials', 1000);
    parser.addParameter('Confidence',   99);

    if is2D
        parser.addParameter('MaxDistance',  1.5);
    else
        parser.addParameter('MaxDistance',  1);
    end

    % Parse and check optional parameters
    parser.parse(varargin{:});
    r = parser.Results;

    maxNumTrials = r.MaxNumTrials;
    confidence   = r.Confidence;
    maxDistance  = r.MaxDistance;

else
    % Instantiate an input parser
    parms = struct( ...
        'MaxNumTrials',       uint32(0), ...
        'Confidence',         uint32(0), ...
        'MaxDistance',        uint32(0));

    popt = struct( ...
        'CaseSensitivity', false, ...
        'StructExpand',    true, ...
        'PartialMatching', false);

    % Specify the optional parameters
    optarg       = eml_parse_parameter_inputs(parms, popt,...
        varargin{:});
    maxNumTrials = eml_get_parameter_value(optarg.MaxNumTrials,...
        1000, varargin{:});
    confidence   = eml_get_parameter_value(optarg.Confidence,...
        99, varargin{:});
    if is2D
        maxDistance  = eml_get_parameter_value(optarg.MaxDistance,...
            1.5, varargin{:});
    else
        maxDistance  = eml_get_parameter_value(optarg.MaxDistance,...
            1.0, varargin{:});
    end
end

if is2D
    [points1, points2] = vision.internal.inputValidation.checkAndConvertMatchedPoints(...
        matchedPoints1, matchedPoints2, ...
        fileName, 'matchedPoints1', 'matchedPoints2');
    [sampleSize, tformType] = checkTransformType2d(char(transformType), fileName);
else %3D
    check3DMatchedPoints(matchedPoints1, matchedPoints2, fileName)
    points1 = matchedPoints1;
    points2 = matchedPoints2;
    [sampleSize, tformType] = checkTransformType3d(char(transformType), fileName);
end

status  = checkPointsSize(statusCode, sampleSize, points1);

% Check optional parameters
checkMaxNumTrials(maxNumTrials, fileName);
checkConfidence(confidence, fileName);
checkMaxDistance(maxDistance, fileName);

classToUse = getClassToUse(points1, points2);

ransacParams.maxNumTrials = int32(maxNumTrials);
ransacParams.confidence   = cast(confidence,  classToUse);
ransacParams.maxDistance  = cast(maxDistance, classToUse);
ransacParams.recomputeModelFromInliers = true;

% Must return sampleSize separately, because it stops being a constant
% as soon as it is placed into the struct.
sampleSize = cast(sampleSize,  classToUse);
ransacParams.sampleSize = sampleSize;

end

function check3DMatchedPoints(points1, points2, fileName)
varName1 = 'matchedPoints1';
varName2 = 'matchedPoints2';
coder.internal.errorIf( ...
    ~isequal(class(points1), class(points2)), ...
    'vision:points:ptsClassMismatch', varName1, varName2);

check3DPoints(points1, varName1, fileName);
check3DPoints(points2, varName2, fileName);

coder.internal.errorIf(~isequal(size(points1), size(points2)), ...
    'vision:points:numPtsMismatch', varName1, varName2);
end

function check3DPoints(points, varName, fileName)
coder.internal.errorIf(~isnumeric(points),...
    'vision:points:ptsClassInvalid', varName);

if isa(points, 'gpuArray')
    str = class(points);
    cmd = sprintf('<a href="matlab:help %s/gather">gather</a>', str);
    error(message('vision:points:gpuArrayNotSupportedForPtArr', cmd));
end

validateattributes(points, {'numeric'}, ...
    {'2d', 'nonsparse', 'real', 'ncols', 3}, fileName, varName);
end


function [sampleSize, tformType] = checkTransformType2d(value, fileName)
list = {'rigid', 'similarity', 'affine', 'projective'};
validatestring(value, list, fileName, 'TransformType');

tformType = lower(value(1));

switch(tformType)
    case 'r'
        sampleSize = 1;
    case 's'
        sampleSize = 2;
    case 'a'
        sampleSize = 3;
    otherwise
        sampleSize = 4;
end
end

function [sampleSize, tformType] = checkTransformType3d(value, fileName)
list = {'rigid', 'similarity'};
validatestring(value, list, fileName, 'TransformType');

tformType = lower(value(1));

sampleSize = 3;
end

function status = checkPointsSize(statusCode, sampleSize, points1)
if size(points1,1) < sampleSize
    status = statusCode.NotEnoughPts;
else
    status = statusCode.NoError;
end
end

function r = checkMaxNumTrials(value, fileName)
validateattributes(value, {'numeric'}, ...
    {'scalar', 'nonsparse', 'real', 'integer', 'positive', 'finite'},...
    fileName, 'MaxNumTrials');
r = 1;
end

function r = checkConfidence(value, fileName)
validateattributes(value, {'numeric'}, ...
    {'scalar', 'nonsparse', 'real', 'positive', 'finite', '<', 100},...
    fileName, 'Confidence');
r = 1;
end

function r = checkMaxDistance(value, fileName)
validateattributes(value, {'numeric'}, ...
    {'scalar', 'nonsparse', 'real', 'positive', 'finite'},...
    fileName, 'MaxDistance');
r = 1;
end

function c = getClassToUse(points1, points2)
if isa(points1, 'double') || isa(points2, 'double')
    c = 'double';
else
    c = 'single';
end
end