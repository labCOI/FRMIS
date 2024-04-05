% computeRigidTransform(points1, points2) Fit a rigid transformation between two sets of 2-D or 3-D points
%  [R, t] = computeRigidTransform(points1, points2) computes a rigid
%  transformation between two sets of matched 2-D or 3-D points. points1
%  and points2 can be M-by-2 arrays of [x,y] coordinates or M-by-3 arrays
%  of [x,y,z] coordinates. For 2-D points, R is a 2-by-2 rotation matrix
%  and t is a 1-by-2 translation vector. For 3-D points, R is a 3-by-3
%  rotation matrix and t is a 1-by-3 translation vector.
%
%  If the number of points is greater than 3, computeRigidTransform
%  computes a least-squares fit.
%
%  Note: the function returns t as a column vector, and R in the
%  post-multiply convention (matrix times column vector). R and t must be
%  transposed to be used in most CVT functions.
%
%  References
%  ----------
%  Arun KS, Huang TS, Blostein SD (1987) Least-squares fitting of two 3-D
%  point sets. IEEE Trans Pattern Anal Machine Intell 9:698–700

% Copyright 2016-2020 MathWorks, Inc.

%#codegen

function [R, t] = computeRigidTransform_costumized(p, q)

% % Compute the translation
R  = [1 0 ; 0 1];
if size(q,1 ) == 1
    t =q-p;
else
    t = mean(q)-mean(p);
end
end