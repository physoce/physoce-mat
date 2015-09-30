function  vec = vecshape(matrix);

% vec = vecshape(matrix)
% -----------------------------
% Reshapes any matrix as a column vector, using the built-in 'reshape' command.
% The length of the vector is the product of the length of the matrix's dimensions.
% For example, an m x n x p matrix become a vector of length (m*n*p). Default is 
% column vector. Row vectors can be obtained by inputing 'row' as the second 
% argument.
%
% vec = reshape(matrix, prod(size(matrix)), 1);
%
% Tom Connolly, April 2007

vec = reshape(matrix, prod(size(matrix)), 1);