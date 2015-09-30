function X = naninterp(X,interp,extrap)
% NaNInterp - Interpolate over NaNs
% INPUTS:
%   X - data vector containing NaNs
%   interp - type of interpolation.  This must correspond with the accepted
%   types for interp1 (nearest,next,previous,linear,etc.)
% OUTPUTS:
%   X - data vector with NaNs inpterolated over.
% See INTERP1 for more info
if extrap ==1
    X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), ...
    find(isnan(X)),interp,'extrap');
else
    X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), ...
    find(isnan(X)),interp);
end
return